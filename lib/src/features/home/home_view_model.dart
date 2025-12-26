import 'dart:async';
import 'dart:io'; // Added for File and FileMode
import 'dart:convert'; // Added for JSON
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:drift/drift.dart' hide Column;
import '../database/database_provider.dart';
import '../database/app_database.dart';
import '../calendar/calendar_service.dart';
import '../ai/ai_service.dart'; // Added AI Service

// --- State Models ---
class EventItem {
  final int id;
  final String title;
  final String dateLabel;
  final DateTime date;
  final String type;
  final IconData icon;
  final Color color;
  final String source;
  final int daysAway;
  final List<Map<String, String>> recipients; // Added recipients list

  const EventItem({
    required this.id,
    required this.title, 
    required this.dateLabel, 
    required this.date,
    required this.type,
    required this.icon, 
    required this.color,
    this.source = '',
    this.daysAway = 999,
    this.recipients = const [],
  });
}

class HomeState {
  final int sentCount;
  final int totalGoal;
  final List<DailyPlan> todayPlans;
  final List<EventItem> upcomingEvents;
  final bool isLoading;

  const HomeState({
    this.sentCount = 0,
    this.totalGoal = 5,
    this.todayPlans = const [],
    this.upcomingEvents = const [],
    this.isLoading = true,
  });

  HomeState copyWith({
    int? sentCount,
    int? totalGoal,
    List<DailyPlan>? todayPlans,
    List<EventItem>? upcomingEvents,
    bool? isLoading,
  }) {
    return HomeState(
      sentCount: sentCount ?? this.sentCount,
      totalGoal: totalGoal ?? this.totalGoal,
      todayPlans: todayPlans ?? this.todayPlans,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// --- ViewModel ---
class HomeViewModel extends StateNotifier<HomeState> {
  final Ref ref;
  
  HomeViewModel(this.ref) : super(const HomeState()) {
    // We defer loadData to be called manually or explicitly initially? 
    // Usually auto-load is fine.
    loadData();
  }

  Future<void> loadData() async {
    final db = ref.read(appDatabaseProvider);
    final calendarService = ref.read(calendarServiceProvider);
    // AI Service for Name Extraction
    final aiService = AiService(); 
    
    // 0. Mock 데이터 삭제 (이전에 저장된 테스트용 데이터 정리)
    await db.deleteMockPlans();
    
    // 1. Generate Base Plans (Holidays, Birthdays)
    await db.generateWeeklyPlans();
    
    // 2. Sent Count
    final count = await db.getTodaySentCount();
    
    // 3. Prepare Data
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final endCalc = today.add(const Duration(days: 45));
    
    // 4. Sync Calendar Events to DailyPlans
    // Fetch current plans first to check duplicates
    var plans = await db.getFuturePlans(today);
    final calEvents = await calendarService.getEvents(today, endCalc);
    final contacts = await db.getAllContacts(); // Get contacts for filtering
    
    bool newPlansAdded = false;
    for (var e in calEvents) {
       // AI Extraction Logic & Direct Matching
       // "스캐줄에 포함된 이름을 인공지능이 타이틀 및 내용에서 사람 이름을 가져오는 기능"
       
       final extractedNames = await aiService.extractNames(e.title);
       final Set<String> matchedPhones = {};
       final List<Map<String, String>> recipientList = [];
       
       // 1. Process AI Extracted Names
       if (extractedNames.isNotEmpty && extractedNames != "NOTHING") {
           final names = extractedNames.split(',').map((s) => s.trim()).toList();
           for (var name in names) {
               if (name.isEmpty) continue;
               // Find contacts matching name (LIKE search logic)
               // Normalize for matching: remove spaces
               final cleanName = name.replaceAll(' ', '');
               final matches = contacts.where((c) {
                  final cleanContactName = c.name.replaceAll(' ', '');
                  return cleanContactName.contains(cleanName) || cleanName.contains(cleanContactName);
               }).toList();
               
               for (var match in matches) {
                   if (matchedPhones.add(match.phone)) {
                       recipientList.add({'name': match.name, 'phone': match.phone});
                   }
               }
           }
       } 

       // 2. Direct String Matching (Fallback & Complementary)
       // Check if title itself contains any contact name explicitly
       // Also normalize spaces to handle "김 종 국" matching "김종국생일"
       final cleanTitle = e.title.replaceAll(' ', '');
       final directMatches = contacts.where((c) {
           final cleanContactName = c.name.replaceAll(' ', '');
           if (cleanContactName.isEmpty) return false;
           return cleanTitle.contains(cleanContactName);
       }).toList();

       for (var match in directMatches) {
           if (matchedPhones.add(match.phone)) {
               recipientList.add({'name': match.name, 'phone': match.phone});
           }
       }

       if (recipientList.isEmpty) {
          // Even if no recipients, check if we need to insert the calendar event
          // But continue if we only want to sync events with recipients? 
          // User said "events have names but no recipients saved", implying events exist.
          // Let's proceed to check existence.
       }

       final eDate = DateTime(e.date.year, e.date.month, e.date.day);
       
       // Check if this event already exists in plans
       DailyPlan? existingPlan;
       try {
         existingPlan = plans.firstWhere((p) => 
            p.date.year == eDate.year && 
            p.date.month == eDate.month && 
            p.date.day == eDate.day && 
            (p.content == e.title || p.content.contains(e.title))
         );
       } catch (_) {
         existingPlan = null;
       }
       
       if (existingPlan == null) {
          // 모든 캘린더 이벤트를 DB에 추가 (수신자가 없어도)
          
          await db.insertPlan(DailyPlansCompanion.insert(
             date: eDate,
             content: e.title,
             type: Value(e.type),
             goalCount: Value(5),
             isGenerated: Value(false),
             sortOrder: Value(0),
             isCompleted: Value(false),
             recipients: Value(recipientList.isEmpty ? null : jsonEncode(recipientList)),
          ));
          newPlansAdded = true;
       } else {
          // UPDATE: If plan exists but has no recipients (NULL), and we found some now.
          // Note: We do NOT update if recipients is '[]' (empty list), as that implies user manually cleared it.
          // Also check if recipients is empty string or "null" string just in case
          final currentRecipients = existingPlan.recipients;
          final isRecipientsNull = currentRecipients == null;
          
          if (isRecipientsNull && recipientList.isNotEmpty) {
              print('[HomeViewModel] Auto-updating recipients for plan ${existingPlan.id} (${existingPlan.content}): $recipientList');
              await db.updatePlanRecipients(existingPlan.id, jsonEncode(recipientList));
              newPlansAdded = true; // Trigger reload
          } else {
              if (recipientList.isNotEmpty) {
                 print('[HomeViewModel] Skipped auto-update for plan ${existingPlan.id}. Current recipients: $currentRecipients');
              }
          }
       }
    }
    
    // Reload plans if we added new ones
    if (newPlansAdded) {
       plans = await db.getFuturePlans(today);
    }

    // 5. Separate Today and Future Plans
    final List<DailyPlan> todayPlans = [];
    final List<EventItem> futureEvents = [];
    int todayGoal = 0; // Default to 0, will update if plans exist

    // First, count ALL today's plans for goal (including completed ones)
    final allTodayPlans = plans.where((p) {
      final diff = p.date.difference(today).inDays;
      return diff == 0 && p.content != 'Daily Warmth';
    }).toList();

    todayGoal = allTodayPlans.length;
    
    // Calculate Sent Count based on completed plans
    final sentCount = allTodayPlans.where((p) => p.isCompleted).length;

    for (var plan in plans) {
       final diff = plan.date.difference(today).inDays;
       if (diff < 0) continue; // Safety check
       
       // Parse recipients
       List<Map<String, String>> recipients = [];
       if (plan.recipients != null) {
        try {
          final List<dynamic> list = jsonDecode(plan.recipients!);
          recipients = list.map((e) => Map<String, String>.from(e)).toList();
        } catch (e) {
          print('[HomeViewModel] Error parsing recipients for plan ${plan.id}: $e');
        }
      }

       // Today Plans & Extended Range (D-5)
       // "내일이 성탄절 D-5 까지 오늘의 카드로 올려줘"
       if (diff >= 0 && diff <= 5) {
          // Add to Today Plans if not completed
          if (!plan.isCompleted) {
             if (plan.content != 'Daily Warmth') {
                todayPlans.add(plan);
             }
          }
       } 
       else {
          // Future Events (D-6+)
          if (plan.content == 'Daily Warmth') continue;

           // Map to EventItem
           IconData icon = FontAwesomeIcons.calendarDay;
           Color color = Colors.blueAccent;
           
           switch(plan.type) {
              case 'Holiday': 
                 icon = FontAwesomeIcons.flag; 
                 color = Colors.redAccent; 
                 break;
              case 'Birthday': 
                 icon = FontAwesomeIcons.cakeCandles; 
                 color = Colors.orangeAccent; 
                 break;
              case 'Anniversary': 
                 icon = FontAwesomeIcons.heart; 
                 color = Colors.pinkAccent; 
                 break;
              case 'Work':
                 icon = FontAwesomeIcons.briefcase;
                 color = Colors.brown;
                 break;
              case 'Personal':
                 icon = FontAwesomeIcons.user;
                 color = Colors.green; 
                 break;
              case 'Important':
                 icon = FontAwesomeIcons.star;
                 color = Colors.amber;
                 break;
           }
           
           futureEvents.add(EventItem(
              id: plan.id,
              title: plan.content,
              dateLabel: _getLabel(diff),
              date: plan.date,
              type: plan.type,
              icon: icon,
              color: color,
              source: plan.isGenerated ? 'App' : 'Calendar',
              daysAway: diff,
              recipients: recipients,
           ));
       }
    }
    
    // Sort Today Plans (by sortOrder) - Already sorted by DB query but we used getFuturePlans which sorts by date then sortOrder.
    // Filtered list preserves order.

    // Sort Future Events
    futureEvents.sort((a, b) => a.daysAway.compareTo(b.daysAway));
    
    state = state.copyWith(
      sentCount: sentCount,
      totalGoal: todayGoal,
      todayPlans: todayPlans,
      upcomingEvents: futureEvents,
      isLoading: false,
    );
  }
  
  String _getLabel(int diff) {
     if (diff == 0) return "Today";
     if (diff == 1) return "Tomorrow";
     return "D-$diff";
  }
  
  void refresh() {
      loadData();
  }

  // --- Actions ---
  Future<void> deletePlan(int id) async {
    final db = ref.read(appDatabaseProvider);
    await db.deletePlan(id);
    loadData();
  }

  Future<void> completePlan(int id) async {
    final db = ref.read(appDatabaseProvider);
    await db.completePlan(id);
    loadData();
  }

  Future<void> movePlanToEnd(int id) async {
    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await db.movePlanToEnd(id, today);
    loadData();
  }

  Future<void> reschedulePlan(int id, DateTime newDate) async {
    final db = ref.read(appDatabaseProvider);
    final targetDate = DateTime(newDate.year, newDate.month, newDate.day);
    await db.reschedulePlan(id, targetDate);
    loadData();
  }

  Future<void> updatePlanIcon(int id, String newType) async {
    final db = ref.read(appDatabaseProvider);
    await db.updatePlanType(id, newType);
    loadData();
  }

  Future<void> updatePlanTitle(int id, String newTitle) async {
    final db = ref.read(appDatabaseProvider);
    // Since we don't have a direct updateTitle method in AppDatabase yet, we'll implement it or use raw SQL.
    // Better: Add updatePlanTitle to AppDatabase. But for now, let's check AppDatabase.
    // Assuming we need to add it.
    await db.updatePlanContent(id, newTitle);
    loadData();
  }

  Future<void> updateScheduleDetails(int id, String title, DateTime date, String type, {List<Map<String, String>> recipients = const []}) async {
    final db = ref.read(appDatabaseProvider);
    final jsonRecipients = jsonEncode(recipients);
    final logMsg = '[HomeViewModel] Updating schedule $id with recipients: $jsonRecipients';
    print(logMsg);
    _logToDebugFile(logMsg);
    
    await db.updatePlanDetailsWithRecipients(id, title, date, type, jsonRecipients);
    
    // Verify update
    final updatedPlan = await db.getPlan(id);
    _logToDebugFile('[HomeViewModel] Verified update for plan $id. New recipients in DB: ${updatedPlan.recipients}');
    
    loadData();
  }

  Future<void> addSchedule(String title, DateTime date, {String type = 'Schedule', List<Map<String, String>> recipients = const []}) async {
    final db = ref.read(appDatabaseProvider);
    final calendarService = ref.read(calendarServiceProvider);
    final aiService = AiService();

    // 1. AI Name Extraction if recipients are empty
    List<Map<String, String>> finalRecipients = [...recipients];
    if (finalRecipients.isEmpty) {
      try {
        final extractedNames = await aiService.extractNames(title);
        if (extractedNames.isNotEmpty && extractedNames != "NOTHING") {
           final contacts = await db.getAllContacts();
           final names = extractedNames.split(',').map((s) => s.trim()).toList();
           final Set<String> matchedPhones = {};
           
           for (var name in names) {
               if (name.isEmpty) continue;
               final cleanName = name.replaceAll(' ', '');
               final matches = contacts.where((c) {
                  final cleanContactName = c.name.replaceAll(' ', '');
                  return cleanContactName.contains(cleanName) || cleanName.contains(cleanContactName);
               }).toList();
               
               for (var match in matches) {
                   if (matchedPhones.add(match.phone)) {
                       finalRecipients.add({'name': match.name, 'phone': match.phone});
                   }
               }
           }
           _logToDebugFile('[HomeViewModel] AI extracted recipients for "$title": $finalRecipients');
        }
      } catch (e) {
        _logToDebugFile('[HomeViewModel] AI extraction error: $e');
      }
    }

    // 2. Add to Device Calendar
    await calendarService.addEvent(title, date);

    // 3. Add to Local DB
    await db.insertPlan(DailyPlansCompanion.insert(
      date: date,
      content: title,
      type: Value(type),
      goalCount: const Value(5),
      isGenerated: const Value(false),
      sortOrder: const Value(0),
      isCompleted: const Value(false),
      recipients: Value(jsonEncode(finalRecipients)),
    ));

    // 4. Refresh
    loadData();
  }

  Future<void> _logToDebugFile(String message) async {
    try {
      final file = File('Assets/Debug/debug.txt');
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      final timestamp = DateTime.now().toString();
      final logLine = '$timestamp: $message\n';
      
      // Write to file
      await file.writeAsString(logLine, mode: FileMode.append);
      
      // Also print to console for immediate visibility if user is monitoring console
      print('DEBUG_LOG: $logLine');
    } catch (e) {
      print('Failed to write to debug file: $e');
    }
  }

  Future<void> activateFuturePlan(int id) async {
    final db = ref.read(appDatabaseProvider);
    try {
      final plan = await db.getPlan(id);
      
      // Check if already in todayPlans
      final existingIndex = state.todayPlans.indexWhere((p) => p.id == plan.id);
      
      if (existingIndex != -1) {
        // Already exists, just ensure sorted (optional, but good for consistency)
        final List<DailyPlan> updatedPlans = List<DailyPlan>.from(state.todayPlans);
        // Re-sort to maintain date order
        updatedPlans.sort((a, b) {
          final dateComp = a.date.compareTo(b.date);
          if (dateComp != 0) return dateComp;
          return a.sortOrder.compareTo(b.sortOrder);
        });
        state = state.copyWith(todayPlans: updatedPlans);
      } else {
        // Add and sort
        final updatedPlans = [...state.todayPlans, plan];
        updatedPlans.sort((a, b) {
          final dateComp = a.date.compareTo(b.date);
          if (dateComp != 0) return dateComp;
          return a.sortOrder.compareTo(b.sortOrder);
        });
        state = state.copyWith(todayPlans: updatedPlans);
      }
    } catch (e) {
      debugPrint("Error activating plan: $e");
    }
  }
}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel(ref);
});
