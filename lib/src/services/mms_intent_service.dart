import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// MMS Intent 서비스
/// 이미지와 함께 기본 문자 앱을 열어 사용자가 발송하도록 합니다.
class MmsIntentService {
  
  // Android Method Channel
  static const _channel = MethodChannel('com.heartconnect/mms');
  
  /// MMS Intent로 문자 앱 열기 (이미지 첨부)
  /// [phoneNumber]: 수신자 전화번호
  /// [imagePath]: 첨부할 이미지 경로
  /// [message]: 본문 메시지 (선택)
  /// Returns: 성공 여부
  static Future<bool> sendMmsIntent({
    required String phoneNumber,
    required String imagePath,
    String? message,
  }) async {
    try {
      // 전화번호 정규화 (숫자만)
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      if (cleanPhone.length < 10 || cleanPhone.length > 11) {
        debugPrint('[MmsIntent] 잘못된 전화번호: $cleanPhone');
        return false;
      }
      
      // 이미지 파일 확인
      final file = File(imagePath);
      if (!await file.exists()) {
        debugPrint('[MmsIntent] 이미지 파일 없음: $imagePath');
        return false;
      }
      
      debugPrint('[MmsIntent] MMS Intent 시작: $cleanPhone, 이미지: $imagePath');
      
      if (Platform.isAndroid) {
        // Android: Method Channel로 MMS Intent 실행
        try {
          final result = await _channel.invokeMethod<bool>('sendMms', {
            'phone': cleanPhone,
            'imagePath': imagePath,
            'message': message ?? '',
          });
          
          if (result == true) {
            debugPrint('[MmsIntent] Android Intent 성공');
            return true;
          }
        } catch (e) {
          debugPrint('[MmsIntent] Method Channel 오류: $e');
        }
        
        // Fallback: share_plus 사용
        return await _shareWithPhone(cleanPhone, imagePath, message);
      } else if (Platform.isIOS) {
        // iOS: share_plus 사용
        return await _shareWithPhone(cleanPhone, imagePath, message);
      }
      
      return false;
    } catch (e) {
      debugPrint('[MmsIntent] 오류: $e');
      return false;
    }
  }
  
  /// share_plus를 사용한 공유 (Fallback)
  static Future<bool> _shareWithPhone(String phone, String imagePath, String? message) async {
    try {
      debugPrint('[MmsIntent] share_plus 사용');
      
      final result = await Share.shareXFiles(
        [XFile(imagePath)],
        text: message ?? '',
        subject: '카드를 보내드립니다',
      );
      
      debugPrint('[MmsIntent] 공유 결과: ${result.status}');
      return result.status == ShareResultStatus.success || 
             result.status == ShareResultStatus.dismissed;
    } catch (e) {
      debugPrint('[MmsIntent] share_plus 오류: $e');
      return false;
    }
  }
  
  /// SMS Intent로 문자 앱 열기 (텍스트만)
  static Future<bool> sendSmsIntent({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      if (cleanPhone.length < 10 || cleanPhone.length > 11) {
        debugPrint('[SmsIntent] 잘못된 전화번호: $cleanPhone');
        return false;
      }
      
      // SMS URI 생성
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: cleanPhone,
        queryParameters: {'body': message},
      );
      
      debugPrint('[SmsIntent] SMS 앱 열기: $cleanPhone');
      
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        return true;
      } else {
        debugPrint('[SmsIntent] SMS 앱을 열 수 없습니다');
        return false;
      }
    } catch (e) {
      debugPrint('[SmsIntent] 오류: $e');
      return false;
    }
  }
  
  /// 여러 수신자에게 순차적으로 MMS Intent 실행
  /// 각 수신자마다 문자 앱이 열리고, 사용자가 발송해야 합니다.
  /// [onProgress]: 진행 상황 콜백 (현재 인덱스, 총 개수, 현재 수신자)
  /// [onUserAction]: 사용자 액션 대기 콜백 (다음 진행 여부 반환)
  static Future<int> sendMmsToMultiple({
    required List<String> phoneNumbers,
    required String imagePath,
    String? message,
    Function(int current, int total, String recipient)? onProgress,
    Future<bool> Function()? onUserAction,
  }) async {
    int successCount = 0;
    
    for (int i = 0; i < phoneNumbers.length; i++) {
      final phone = phoneNumbers[i];
      
      // 진행 상황 알림
      onProgress?.call(i + 1, phoneNumbers.length, phone);
      
      // MMS Intent 실행
      final success = await sendMmsIntent(
        phoneNumber: phone,
        imagePath: imagePath,
        message: message,
      );
      
      if (success) successCount++;
      
      // 마지막이 아니면 사용자 액션 대기
      if (i < phoneNumbers.length - 1) {
        if (onUserAction != null) {
          final continueNext = await onUserAction();
          if (!continueNext) break;
        } else {
          // 기본 대기 시간
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }
    
    return successCount;
  }
}
