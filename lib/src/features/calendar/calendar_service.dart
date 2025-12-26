import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

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

  Future<void> _initTimezone() async {
    if (!_isTimezoneInitialized) {
      tz.initializeTimeZones();
      _isTimezoneInitialized = true;
    }
  }

  Future<List<CalendarEventData>> getEvents(DateTime start, DateTime end) async {
    final events = <CalendarEventData>[];

    // Mobile Integration - 실제 디바이스 캘린더 연동
    // device_calendar 패키지가 구글 캘린더, 네이버 캘린더, Samsung 캘린더 등
    // 디바이스에 등록된 모든 캘린더 계정을 자동으로 읽어옵니다.
    if (Platform.isAndroid || Platform.isIOS) {
       try {
         var permissions = await _deviceCalendar.hasPermissions();
         if (permissions.isSuccess && !permissions.data!) {
             permissions = await _deviceCalendar.requestPermissions();
         }
         
         if (permissions.isSuccess && permissions.data!) {
            final calendars = await _deviceCalendar.retrieveCalendars();
            debugPrint('[CalendarService] Found ${calendars.data?.length ?? 0} calendars');
            
            if (calendars.isSuccess && calendars.data != null) {
               for (var cal in calendars.data!) {
                   debugPrint('[CalendarService] Reading calendar: ${cal.name} (${cal.accountName}) - ${_determineSource(cal)}');
                   
                   final evResult = await _deviceCalendar.retrieveEvents(
                      cal.id, 
                      RetrieveEventsParams(startDate: start, endDate: end)
                   );
                   if (evResult.isSuccess && evResult.data != null) {
                      debugPrint('[CalendarService] Found ${evResult.data!.length} events in ${cal.name}');
                      
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
         } else {
            debugPrint('[CalendarService] Calendar permission denied');
         }
       } catch (e) {
         debugPrint("[CalendarService] Calendar Sync Error: $e");
       }
    } 
    
    // Windows에서만 Mock Data 사용 (개발/테스트용)
    if (Platform.isWindows) {
        events.addAll(_getMockEvents(start, end));
    }
    
    // Sort by date
    events.sort((a, b) => a.date.compareTo(b.date));
    debugPrint('[CalendarService] Total events loaded: ${events.length}');
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
