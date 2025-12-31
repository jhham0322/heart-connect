import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;
  static bool _tzInitialized = false;

  static Future<void> initialize(GoRouter goRouter) async {
    if (_isInitialized) return;

    // timezone 초기화
    if (!_tzInitialized) {
      tz_data.initializeTimeZones();
      _tzInitialized = true;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    try {
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null) {
            goRouter.push('/alarm?message=${Uri.encodeComponent(response.payload!)}');
          }
        },
      );
      
      // Android에서 알림 권한 요청
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
          
    } catch (e) {
      final message = e.toString();
      if (message.contains('LateInitializationError') || message.contains('has not been initialized')) {
        return;
      }
      print('[NotificationService] 초기화 오류: $e');
    }

    _isInitialized = true;
    
    // 저장된 알림 시간으로 스케줄 설정
    await _scheduleFromSettings();
  }

  // 설정에서 알림 시간 로드 후 스케줄링
  static Future<void> _scheduleFromSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('notifications_enabled') ?? true;
      
      if (!enabled) {
        await cancelDailyReminder();
        return;
      }
      
      final timeStr = prefs.getString('notification_time') ?? '9:0';
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      await scheduleDailyReminder(hour: hour, minute: minute);
    } catch (e) {
      print('[NotificationService] 설정 로드 오류: $e');
    }
  }

  // 즉시 알림 표시
  static Future<void> showNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'default_channel',
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0, // ID
      title,
      body,
      notificationDetails,
      payload: body,
    );
  }

  // 매일 특정 시간에 알림 스케줄링
  static Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    try {
      await cancelDailyReminder(); // 기존 스케줄 취소
      
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'daily_reminder',
        '일일 알림',
        channelDescription: '매일 설정된 시간에 알림을 보냅니다',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      // 다음 알림 시간 계산
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      
      // 이미 지난 시간이면 다음날로
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        1, // Daily reminder ID
        '💝 ConnectHeart',
        '오늘 소중한 사람에게 마음을 전해보세요!',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // 매일 같은 시간에 반복
      );

      print('[NotificationService] 알림 스케줄됨: $hour:$minute (다음 알림: $scheduledDate)');
    } catch (e) {
      print('[NotificationService] 스케줄링 오류: $e');
    }
  }

  // 알림 스케줄 취소
  static Future<void> cancelDailyReminder() async {
    await _flutterLocalNotificationsPlugin.cancel(1);
  }

  // 모든 알림 취소
  static Future<void> cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
  
  // 설정 변경 시 호출
  static Future<void> updateSchedule() async {
    await _scheduleFromSettings();
  }
}
