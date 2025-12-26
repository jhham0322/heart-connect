import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CalendarEventData {
  final String title;
  final DateTime date;
  final String type; // 'Holiday', 'Birthday', 'Anniversary', 'Schedule'
  final String source; // 'Google', 'Naver', 'Device'

  CalendarEventData({
    required this.title, 
    required this.date, 
    required this.type, 
    required this.source
  });
}

class CalendarService {
  final DeviceCalendarPlugin _deviceCalendar = DeviceCalendarPlugin();
  bool _isTimezoneInitialized = false;
  
  // Native calendar channel
  static const _calendarChannel = MethodChannel('com.heartconnect/calendar');

  Future<void> _initTimezone() async {
    if (!_isTimezoneInitialized) {
      tz.initializeTimeZones();
      _isTimezoneInitialized = true;
    }
  }

  Future<List<CalendarEventData>> getEvents(DateTime start, DateTime end) async {
    final events = <CalendarEventData>[];

    debugPrint('[CalendarService] Getting events from $start to $end');
    debugPrint('[CalendarService] Platform: ${Platform.isAndroid ? "Android" : Platform.isIOS ? "iOS" : "Other"}');

    // Android: 네이티브 MethodChannel을 통해 직접 ContentProvider 조회
    if (Platform.isAndroid) {
       try {
         final startMillis = start.millisecondsSinceEpoch;
         final endMillis = end.millisecondsSinceEpoch;
         
         debugPrint('[CalendarService] Calling native getCalendarEvents...');
         
         final result = await _calendarChannel.invokeMethod('getCalendarEvents', {
           'start': startMillis,
           'end': endMillis,
         });
         
         if (result != null && result is List) {
           debugPrint('[CalendarService] Native returned ${result.length} events');
           
           for (var item in result) {
             final map = Map<String, dynamic>.from(item);
             final title = map['title'] as String? ?? 'Untitled';
             final startMs = map['startMillis'] as int? ?? 0;
             final source = map['source'] as String? ?? 'Phone';
             final type = map['type'] as String? ?? 'Schedule';
             
             final date = DateTime.fromMillisecondsSinceEpoch(startMs);
             
             debugPrint('[CalendarService] Event: "$title" on $date from $source');
             
             events.add(CalendarEventData(
               title: title,
               date: date,
               type: type,
               source: source,
             ));
           }
         }
       } catch (e, stack) {
         debugPrint("[CalendarService] Native Calendar Error: $e");
         debugPrint("[CalendarService] Stack: $stack");
       }
    }
    // iOS: device_calendar 패키지 사용 (iOS에서는 잘 작동함)
    else if (Platform.isIOS) {
       try {
         var permissions = await _deviceCalendar.hasPermissions();
         if (permissions.isSuccess && !permissions.data!) {
             permissions = await _deviceCalendar.requestPermissions();
         }
         
         if (permissions.isSuccess && permissions.data!) {
            final calendars = await _deviceCalendar.retrieveCalendars();
            
            if (calendars.isSuccess && calendars.data != null) {
               for (var cal in calendars.data!) {
                   final calId = cal.id;
                   if (calId == null) continue;
                   
                   final evResult = await _deviceCalendar.retrieveEvents(
                      calId, 
                      RetrieveEventsParams(startDate: start, endDate: end)
                   );
                   
                   if (evResult.isSuccess && evResult.data != null) {
                      for (var e in evResult.data!) {
                          if (e.start == null) continue;
                          final date = DateTime.fromMillisecondsSinceEpoch(e.start!.millisecondsSinceEpoch);
                          
                          events.add(CalendarEventData(
                             title: e.title ?? 'Event',
                             date: date,
                             type: _guessType(cal.name, e.title),
                             source: _determineSource(cal)
                          ));
                      }
                   }
               }
            }
         }
       } catch (e) {
         debugPrint("[CalendarService] iOS Calendar Error: $e");
       }
    } 
    
    // Windows에서만 Mock Data 사용 (개발/테스트용)
    if (Platform.isWindows) {
        events.addAll(_getMockEvents(start, end));
    }
    
    // Sort by date
    events.sort((a, b) => a.date.compareTo(b.date));
    debugPrint('[CalendarService] ====== Total events loaded: ${events.length} ======');
    return events;
  }

  Future<bool> addEvent(String title, DateTime date) async {
    if (Platform.isWindows) {
        debugPrint("Windows: Event added to calendar (simulated): $title at $date");
        return true;
    }

    try {
      await _initTimezone();

      var permissions = await _deviceCalendar.hasPermissions();
      if (permissions.isSuccess && !permissions.data!) {
        permissions = await _deviceCalendar.requestPermissions();
      }

      if (permissions.isSuccess && permissions.data!) {
        final calendars = await _deviceCalendar.retrieveCalendars();
        if (calendars.isSuccess && calendars.data != null && calendars.data!.isNotEmpty) {
           // Use the first writable calendar or just the first one
           final calendar = calendars.data!.firstWhere((c) => c.isReadOnly == false, orElse: () => calendars.data!.first);
           
           // Use local location (default from timezone package)
           final location = local;
           final tzDate = TZDateTime.from(date, location);
           
           final event = Event(
              calendar.id,
              title: title,
              start: tzDate,
              end: tzDate.add(const Duration(hours: 1)),
              allDay: true,
           );
           
           final result = await _deviceCalendar.createOrUpdateEvent(event);
           return result?.isSuccess ?? false;
        }
      }
    } catch (e) {
      debugPrint("Error adding event to device calendar: $e");
    }
    return false;
  }

  String _determineSource(Calendar cal) {
    // Try to determine source from account info
    // Note: device_calendar 4.x Calendar object has 'accountName' and 'accountType' (Android)
    final type = (cal.accountType ?? '').toLowerCase();
    final name = (cal.accountName ?? '').toLowerCase();
    final calName = (cal.name ?? '').toLowerCase();

    if (type.contains('google') || name.contains('gmail') || calName.contains('google')) {
      return 'Google Calendar';
    }
    if (type.contains('naver') || name.contains('naver') || calName.contains('naver')) {
      return 'Naver Calendar';
    }
    if (type.contains('icloud') || calName.contains('icloud')) {
      return 'iCloud';
    }
    if (name.contains('outlook') || name.contains('hotmail')) {
      return 'Outlook';
    }
    
    return cal.accountName ?? 'Phone';
  }

  String _guessType(String? calName, String? title) {
    final c = (calName ?? '').toLowerCase();
    final t = (title ?? '').toLowerCase();
    
    if (c.contains('holiday') || t.contains('holiday') || t.contains('국경일') 
        || t.contains('광복절') || t.contains('christmas') || t.contains('신정') || t.contains('설날')) {
      return 'Holiday';
    }
    if (c.contains('birthday') || t.contains('birthday') || t.contains('생일')) return 'Birthday';
    if (t.contains('anniversary') || t.contains('기념일') || t.contains('d-day') || t.contains('결혼')) return 'Anniversary';
    return 'Schedule';
  }

  List<CalendarEventData> _getMockEvents(DateTime start, DateTime end) {
     final now = DateTime.now();
     
     final mockList = [
       // 1. Google Calendar - Holidays
       CalendarEventData(
         title: 'Christmas (성탄절)',
         date: DateTime(now.year, 12, 25),
         type: 'Holiday',
         source: 'Google Calendar',
       ),
       CalendarEventData(
         title: '신정 (New Year)',
         date: DateTime(now.year + 1, 1, 1),
         type: 'Holiday',
         source: 'Google Calendar',
       ),

       // 2. Naver Calendar - Anniversaries
       CalendarEventData(
         title: '결혼기념일 10주년',
         date: DateTime(now.year, 12, 27),
         type: 'Anniversary',
         source: 'Naver Calendar',
       ),
       
       // 3. Google Calendar - Birthdays (Matching Logic)
       // 유재석: Matches Contact (set to Tomorrow)
       CalendarEventData(
         title: '유재석의 생일', 
         date: now.add(const Duration(days: 1)), 
         type: 'Birthday',
         source: 'Google Calendar',
       ),
       // 박명수: Calendar Only
       CalendarEventData(
         title: '박명수의 생일',
         date: now.add(const Duration(days: 2)), 
         type: 'Birthday',
         source: 'Google Calendar',
       ),
     ];
     
     return mockList.where((e) => 
         e.date.isAfter(start.subtract(const Duration(days:1))) && 
         e.date.isBefore(end.add(const Duration(days:1)))
     ).toList();
  }
}

final calendarServiceProvider = Provider<CalendarService>((ref) => CalendarService());
