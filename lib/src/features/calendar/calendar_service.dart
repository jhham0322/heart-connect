import 'dart:io';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<List<CalendarEventData>> getEvents(DateTime start, DateTime end) async {
    final events = <CalendarEventData>[];

    // Mobile Integration logic
    if (Platform.isAndroid || Platform.isIOS) {
       try {
         var permissions = await _deviceCalendar.hasPermissions();
         if (permissions.isSuccess && !permissions.data!) {
             permissions = await _deviceCalendar.requestPermissions();
         }
         
         if (permissions.isSuccess && permissions.data!) {
            final calendars = await _deviceCalendar.retrieveCalendars();
            if (calendars.isSuccess && calendars.data != null) {
               for (var cal in calendars.data!) {
                   final evResult = await _deviceCalendar.retrieveEvents(
                      cal.id, 
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
                             source: cal.accountName ?? 'Phone'
                          ));
                      }
                   }
               }
            }
         }
       } catch (e) {
         // Silently ignore errors on unsupported platforms or permission issues
       }
    } 
    
    // Filter out duplicates if Mock data overlaps (not implemented here, simple append)
    // Always add Mock Data for demo/PC
    if (Platform.isWindows || events.isEmpty) {
        events.addAll(_getMockEvents(start, end));
    }
    
    // Sort
    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  String _guessType(String? calName, String? title) {
    final c = (calName ?? '').toLowerCase();
    final t = (title ?? '').toLowerCase();
    
    if (c.contains('holiday') || t.contains('holiday') || t.contains('국경일') 
        || t.contains('광복절') || t.contains('christmas') || t.contains('신정') || t.contains('설날')) return 'Holiday';
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
