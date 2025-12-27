import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

/// SMS 발송 서비스
/// Android에서는 기본 메시지 앱을 열거나 네이티브 API 사용
class NativeSmsService {
  
  // Method Channel for native SMS sending
  static const _channel = MethodChannel('com.heartconnect/sms');
  
  /// SMS 발송 권한 확인
  static Future<bool> checkPermission() async {
    if (!Platform.isAndroid) return false;
    
    final status = await Permission.sms.status;
    return status.isGranted;
  }
  
  /// SMS 발송 권한 요청
  static Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return false;
    
    final status = await Permission.sms.request();
    return status.isGranted;
  }
  
  /// SMS 발송 (기본 메시지 앱 열기)
  /// [phoneNumber]: 수신자 전화번호
  /// [message]: 발송할 메시지
  /// Returns: 발송 성공 여부
  static Future<bool> sendSmsViaApp({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // 전화번호 정규화 (숫자만)
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      if (cleanPhone.length < 10 || cleanPhone.length > 11) {
        debugPrint('[NativeSms] 잘못된 전화번호: $cleanPhone');
        return false;
      }
      
      // SMS URL 생성
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: cleanPhone,
        queryParameters: {'body': message},
      );
      
      debugPrint('[NativeSms] SMS 앱 열기: $cleanPhone');
      
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        return true;
      } else {
        debugPrint('[NativeSms] SMS 앱을 열 수 없습니다');
        return false;
      }
    } catch (e) {
      debugPrint('[NativeSms] 오류: $e');
      return false;
    }
  }
  
  /// 네이티브 SMS 발송 (직접 발송, 권한 필요)
  /// Android에서만 동작, SEND_SMS 권한 필요
  static Future<bool> sendSmsNative({
    required String phoneNumber,
    required String message,
  }) async {
    if (!Platform.isAndroid) {
      debugPrint('[NativeSms] Android만 지원됩니다.');
      return false;
    }
    
    try {
      // 전화번호 정규화
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      if (cleanPhone.length < 10 || cleanPhone.length > 11) {
        debugPrint('[NativeSms] 잘못된 전화번호: $cleanPhone');
        return false;
      }
      
      // 권한 확인
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        debugPrint('[NativeSms] SMS 권한이 없습니다. 앱으로 발송합니다.');
        return await sendSmsViaApp(phoneNumber: cleanPhone, message: message);
      }
      
      debugPrint('[NativeSms] 네이티브 발송 시도: $cleanPhone');
      
      // 네이티브 메소드 채널로 발송
      final result = await _channel.invokeMethod<bool>('sendSms', {
        'phone': cleanPhone,
        'message': message,
      });
      
      if (result == true) {
        debugPrint('[NativeSms] 발송 성공: $cleanPhone');
        return true;
      } else {
        debugPrint('[NativeSms] 발송 실패, 앱으로 대체합니다.');
        return await sendSmsViaApp(phoneNumber: cleanPhone, message: message);
      }
    } catch (e) {
      debugPrint('[NativeSms] 네이티브 발송 오류: $e');
      // 오류 시 기본 앱으로 fallback
      return await sendSmsViaApp(phoneNumber: phoneNumber, message: message);
    }
  }
  
  /// SMS 발송 (자동 선택)
  /// 권한이 있으면 네이티브로, 없으면 앱으로
  static Future<bool> sendSms({
    required String phoneNumber,
    required String message,
  }) async {
    // 먼저 네이티브 시도, 실패 시 앱으로 fallback
    return await sendSmsNative(phoneNumber: phoneNumber, message: message);
  }
  
  /// SMS 발송 (여러 수신자)
  static Future<int> sendSmsToMultiple({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    int successCount = 0;
    
    for (final phone in phoneNumbers) {
      final success = await sendSms(phoneNumber: phone, message: message);
      if (success) successCount++;
      
      // 발송 간 간격 (스팸 방지)
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    return successCount;
  }
}
