import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// MMS Intent ?쒕퉬??
/// ?대?吏? ?④퍡 湲곕낯 臾몄옄 ?깆쓣 ?댁뼱 ?ъ슜?먭? 諛쒖넚?섎룄濡??⑸땲??
class MmsIntentService {
  
  // Android Method Channel
  static const _channel = MethodChannel('com.heartconnect/mms');
  
  /// MMS Intent濡?臾몄옄 ???닿린 (?대?吏 泥⑤?)
  /// [phoneNumber]: ?섏떊???꾪솕踰덊샇
  /// [imagePath]: 泥⑤????대?吏 寃쎈줈
  /// [message]: 蹂몃Ц 硫붿떆吏 (?좏깮)
  /// Returns: ?깃났 ?щ?
  static Future<bool> sendMmsIntent({
    required String phoneNumber,
    required String imagePath,
    String? message,
  }) async {
    try {
      // ?꾪솕踰덊샇 ?뺢퇋??(?レ옄留?
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      if (cleanPhone.length < 10 || cleanPhone.length > 11) {
        
        return false;
      }
      
      // ?대?吏 ?뚯씪 ?뺤씤
      final file = File(imagePath);
      if (!await file.exists()) {
        
        return false;
      }
      
      
      
      if (Platform.isAndroid) {
        // Android: Method Channel濡?MMS Intent ?ㅽ뻾
        try {
          
          final result = await _channel.invokeMethod<bool>('sendMms', {
            'phone': cleanPhone,
            'imagePath': imagePath,
            'message': message ?? '',
          });
          
          
          
          if (result == true) {
            
            return true;
          } else {
            debugPrint('[MmsIntent] Android Intent ?ㅽ뙣 (result=$result)');
            // Fallback: share_plus ?ъ슜
            return await _shareWithPhone(cleanPhone, imagePath, message);
          }
        } catch (e) {
          
          // Fallback: share_plus ?ъ슜
          return await _shareWithPhone(cleanPhone, imagePath, message);
        }
      } else if (Platform.isIOS) {
        // iOS: share_plus ?ъ슜
        return await _shareWithPhone(cleanPhone, imagePath, message);
      }
      
      return false;
    } catch (e) {
      
      return false;
    }
  }
  
  /// share_plus瑜??ъ슜??怨듭쑀 (Fallback)
  static Future<bool> _shareWithPhone(String phone, String imagePath, String? message) async {
    try {
      
      
      final result = await Share.shareXFiles(
        [XFile(imagePath)],
        text: message ?? '',
        subject: '移대뱶瑜?蹂대궡?쒕┰?덈떎',
      );
      
      
      return result.status == ShareResultStatus.success || 
             result.status == ShareResultStatus.dismissed;
    } catch (e) {
      
      return false;
    }
  }
  
  /// SMS Intent濡?臾몄옄 ???닿린 (?띿뒪?몃쭔)
  static Future<bool> sendSmsIntent({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      if (cleanPhone.length < 10 || cleanPhone.length > 11) {
        
        return false;
      }
      
      // SMS URI ?앹꽦
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
  
  /// ?щ윭 ?섏떊?먯뿉寃??쒖감?곸쑝濡?MMS Intent ?ㅽ뻾
  /// 媛??섏떊?먮쭏??臾몄옄 ?깆씠 ?대━怨? ?ъ슜?먭? 諛쒖넚?댁빞 ?⑸땲??
  /// [onProgress]: 吏꾪뻾 ?곹솴 肄쒕갚 (?꾩옱 ?몃뜳?? 珥?媛쒖닔, ?꾩옱 ?섏떊??
  /// [onUserAction]: ?ъ슜???≪뀡 ?湲?肄쒕갚 (?ㅼ쓬 吏꾪뻾 ?щ? 諛섑솚)
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
      
      // 吏꾪뻾 ?곹솴 ?뚮┝
      onProgress?.call(i + 1, phoneNumbers.length, phone);
      
      // MMS Intent ?ㅽ뻾
      final success = await sendMmsIntent(
        phoneNumber: phone,
        imagePath: imagePath,
        message: message,
      );
      
      if (success) successCount++;
      
      // 留덉?留됱씠 ?꾨땲硫??ъ슜???≪뀡 ?湲?
      if (i < phoneNumbers.length - 1) {
        if (onUserAction != null) {
          final continueNext = await onUserAction();
          if (!continueNext) break;
        } else {
          // 湲곕낯 ?湲??쒓컙
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }
    
    return successCount;
  }
}

