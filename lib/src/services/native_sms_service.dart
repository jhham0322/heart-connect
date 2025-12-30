import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

/// SMS 諛쒖넚 ?쒕퉬??
/// Android?먯꽌??湲곕낯 硫붿떆吏 ?깆쓣 ?닿굅???ㅼ씠?곕툕 API ?ъ슜
class NativeSmsService {
  
  // Method Channel for native SMS sending
  static const _channel = MethodChannel('com.heartconnect/sms');
  
  /// SMS 諛쒖넚 沅뚰븳 ?뺤씤
  static Future<bool> checkPermission() async {
    if (!Platform.isAndroid) return false;
    
    final status = await Permission.sms.status;
    return status.isGranted;
  }
  
  /// SMS 諛쒖넚 沅뚰븳 ?붿껌
  static Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return false;
    
    final status = await Permission.sms.request();
    return status.isGranted;
  }
  
  /// SMS 諛쒖넚 (湲곕낯 硫붿떆吏 ???닿린)
  /// [phoneNumber]: ?섏떊???꾪솕踰덊샇
  /// [message]: 諛쒖넚??硫붿떆吏
  /// Returns: 諛쒖넚 ?깃났 ?щ?
  static Future<bool> sendSmsViaApp({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // ?꾪솕踰덊샇 ?뺢퇋??(?レ옄留?
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      if (cleanPhone.length < 10 || cleanPhone.length > 11) {
        
        return false;
      }
      
      // SMS URL ?앹꽦
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: cleanPhone,
        queryParameters: {'body': message},
      );
      
      
      
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        return true;
      } else {
        
        return false;
      }
    } catch (e) {
      
      return false;
    }
  }
  
  /// ?ㅼ씠?곕툕 SMS 諛쒖넚 (吏곸젒 諛쒖넚, 沅뚰븳 ?꾩슂)
  /// Android?먯꽌留??숈옉, SEND_SMS 沅뚰븳 ?꾩슂
  static Future<bool> sendSmsNative({
    required String phoneNumber,
    required String message,
  }) async {
    if (!Platform.isAndroid) {
      
      return false;
    }
    
    try {
      // ?꾪솕踰덊샇 ?뺢퇋??
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      if (cleanPhone.length < 10 || cleanPhone.length > 11) {
        
        return false;
      }
      
      // 沅뚰븳 ?뺤씤
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        
        return await sendSmsViaApp(phoneNumber: cleanPhone, message: message);
      }
      
      
      
      // ?ㅼ씠?곕툕 硫붿냼??梨꾨꼸濡?諛쒖넚
      final result = await _channel.invokeMethod<bool>('sendSms', {
        'phone': cleanPhone,
        'message': message,
      });
      
      if (result == true) {
        
        return true;
      } else {
        
        return await sendSmsViaApp(phoneNumber: cleanPhone, message: message);
      }
    } catch (e) {
      
      // ?ㅻ쪟 ??湲곕낯 ?깆쑝濡?fallback
      return await sendSmsViaApp(phoneNumber: phoneNumber, message: message);
    }
  }
  
  /// SMS 諛쒖넚 (?먮룞 ?좏깮)
  /// 沅뚰븳???덉쑝硫??ㅼ씠?곕툕濡? ?놁쑝硫??깆쑝濡?
  static Future<bool> sendSms({
    required String phoneNumber,
    required String message,
  }) async {
    // 癒쇱? ?ㅼ씠?곕툕 ?쒕룄, ?ㅽ뙣 ???깆쑝濡?fallback
    return await sendSmsNative(phoneNumber: phoneNumber, message: message);
  }
  
  /// SMS 諛쒖넚 (?щ윭 ?섏떊??
  static Future<int> sendSmsToMultiple({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    int successCount = 0;
    
    for (final phone in phoneNumbers) {
      final success = await sendSms(phoneNumber: phone, message: message);
      if (success) successCount++;
      
      // 諛쒖넚 媛?媛꾧꺽 (?ㅽ뙵 諛⑹?)
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    return successCount;
  }
}

