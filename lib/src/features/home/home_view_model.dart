import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../database/database_provider.dart';
import '../../theme/app_theme.dart';
import '../calendar/calendar_service.dart';

// --- State Models ---
class EventItem {
  final String title;
  final String dateLabel;
  final IconData icon;
  final Color color;
  final String source; // 'Contacts', 'Google Calendar', etc.
  final int daysAway;  // For sorting
  
  const EventItem({
    required this.title, 
    required this.dateLabel, 
    required this.icon, 
    required this.color,
    this.source = '',
    this.daysAway = 999,
  });
}

class HomeState {
  final int sentCount;
  final int totalGoal;
  final List<EventItem> upcomingEvents;
  final bool isLoading;

  const HomeState({
    this.sentCount = 0,
    this.totalGoal = 5,
    this.upcomingEvents = const [],
    this.isLoading = true,
  });

  HomeState copyWith({
    int? sentCount,
    int? totalGoal,
    List<EventItem>? upcomingEvents,
    bool? isLoading,
  }) {
    return HomeState(
      sentCount: sentCount ?? this.sentCount,
      totalGoal: totalGoal ?? this.totalGoal,
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
    
    // 1. Sent Count
    final count = await db.getTodaySentCount();
    
    // 2. Prepare Data
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endCalc = today.add(const Duration(days: 45));
    
    // Use a Map to handle merging: Key = "YYYY-MM-DD|Name"
    // But since names might differ ("유재석" vs "유재석의 생일"), we need smarter logic or simpler separate lists then merge.
    // Let's use a list and check manually.
    final List<EventItem> allEvents = [];
    
    // A. Contacts Birthdays
    final contacts = await db.getAllContacts();
    for (var c in contacts) {
      if (c.birthday != null) {
        final bday = c.birthday!;
        DateTime nextBday = DateTime(now.year, bday.month, bday.day);
        if (nextBday.isBefore(today)) {
           nextBday = DateTime(now.year + 1, bday.month, bday.day);
        }
        
        final diff = nextBday.difference(today).inDays;
        
        if (diff >= 0 && diff <= 45) {
           allEvents.add(EventItem(
             title: c.name,
             dateLabel: _getLabel(diff),
             icon: FontAwesomeIcons.cakeCandles,
             color: Colors.orange,
             source: 'App Contacts',
             daysAway: diff,
           ));
        }
      }
    }
    
    // B. Calendar Events
    final calEvents = await calendarService.getEvents(today, endCalc);
    
    for (var e in calEvents) {
       final eDate = DateTime(e.date.year, e.date.month, e.date.day);
       final diff = eDate.difference(today).inDays;
       if (diff < 0) continue; // Past
       
       // Check for Merge
       // If same day + Birthday + name match
       bool merged = false;
       if (e.type == 'Birthday') {
           for (int i = 0; i < allEvents.length; i++) {
               final existing = allEvents[i];
               // Check if same day (diff) AND title similarity
               if (existing.daysAway == diff && e.title.contains(existing.title)) {
                   // MERGE
                   allEvents[i] = EventItem(
                       title: existing.title, // Keep simple name
                       dateLabel: existing.dateLabel,
                       icon: existing.icon,
                       color: existing.color, // Keep Contact color preference
                       source: 'Contacts + ${e.source}', // Combine sources
                       daysAway: existing.daysAway
                   );
                   merged = true;
                   break;
               }
           }
       }
       
       if (!merged) {
         // Create New
          IconData icon = FontAwesomeIcons.calendarDay;
          Color color = Colors.blueAccent;
          
          switch(e.type) {
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
             default: 
                // Defaults already set
                break;
          }
          
          allEvents.add(EventItem(
             title: e.title,
             dateLabel: _getLabel(diff),
             icon: icon,
             color: color,
             source: e.source,
             daysAway: diff,
          ));
       }
    }
    
    // Sort by Date (daysAway)
    allEvents.sort((a, b) => a.daysAway.compareTo(b.daysAway));
    
    state = state.copyWith(
      sentCount: count,
      upcomingEvents: allEvents,
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
}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel(ref);
});
