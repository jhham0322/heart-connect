import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:heart_connect/src/l10n/app_strings.dart';

/// 소셜 미디어 공유 서비스
class SocialShareService {
  
  /// 지원하는 소셜 미디어 플랫폼
  static const List<SocialPlatform> platforms = [
    SocialPlatform(
      id: 'share',
      name: '기타 앱으로 공유',
      icon: Icons.share,
      color: Colors.blueGrey,
    ),
    SocialPlatform(
      id: 'kakaotalk',
      name: '카카오톡',
      icon: Icons.chat_bubble,
      color: Color(0xFFFEE500),
      packageAndroid: 'com.kakao.talk',
      schemeIOS: 'kakaotalk://',
    ),
    SocialPlatform(
      id: 'instagram',
      name: '인스타그램',
      icon: Icons.camera_alt,
      color: Color(0xFFE4405F),
      packageAndroid: 'com.instagram.android',
      schemeIOS: 'instagram://',
    ),
    SocialPlatform(
      id: 'facebook',
      name: '페이스북',
      icon: Icons.facebook,
      color: Color(0xFF1877F2),
      packageAndroid: 'com.facebook.katana',
      schemeIOS: 'fb://',
    ),
    SocialPlatform(
      id: 'x',
      name: 'X (트위터)',
      icon: Icons.alternate_email,
      color: Colors.black,
      packageAndroid: 'com.twitter.android',
      schemeIOS: 'twitter://',
    ),
    SocialPlatform(
      id: 'whatsapp',
      name: 'WhatsApp',
      icon: Icons.message,
      color: Color(0xFF25D366),
      packageAndroid: 'com.whatsapp',
      schemeIOS: 'whatsapp://',
    ),
    SocialPlatform(
      id: 'telegram',
      name: '텔레그램',
      icon: Icons.send,
      color: Color(0xFF0088CC),
      packageAndroid: 'org.telegram.messenger',
      schemeIOS: 'tg://',
    ),
  ];

  /// 이미지를 특정 플랫폼으로 공유
  static Future<ShareResult> shareImage({
    required String imagePath,
    required String platformId,
    String? text,
  }) async {
    final file = XFile(imagePath);
    
    if (platformId == 'share') {
      // 기본 공유 (사용자가 앱 선택)
      return await Share.shareXFiles(
        [file],
        text: text ?? '마음을 전합니다 💝',
        subject: 'Heart-Connect 카드',
      );
    }
    
    // 특정 플랫폼으로 공유
    final platform = platforms.firstWhere(
      (p) => p.id == platformId,
      orElse: () => platforms.first,
    );
    
    // 플랫폼별 공유 시도
    switch (platformId) {
      case 'kakaotalk':
        return await _shareToKakao(file, text);
      case 'instagram':
        return await _shareToInstagram(file, text);
      case 'facebook':
        return await _shareToFacebook(file, text);
      case 'x':
        return await _shareToX(file, text);
      default:
        // 기본 공유로 fallback
        return await Share.shareXFiles([file], text: text);
    }
  }

  /// 카카오톡으로 공유
  static Future<ShareResult> _shareToKakao(XFile file, String? text) async {
    try {
      if (Platform.isAndroid) {
        // Android: 카카오톡 앱으로 직접 공유
        return await Share.shareXFiles(
          [file],
          text: text ?? '마음을 전합니다 💝',
        );
      } else if (Platform.isIOS) {
        // iOS: 카카오톡 URL Scheme 사용
        final uri = Uri.parse('kakaotalk://');
        if (await canLaunchUrl(uri)) {
          return await Share.shareXFiles([file], text: text);
        }
      }
    } catch (e) {
      debugPrint('[SocialShare] 카카오톡 공유 오류: $e');
    }
    
    // Fallback: 기본 공유
    return await Share.shareXFiles([file], text: text);
  }

  /// 인스타그램으로 공유 (Stories)
  static Future<ShareResult> _shareToInstagram(XFile file, String? text) async {
    try {
      if (Platform.isAndroid) {
        // Android: 인스타그램 스토리로 공유
        return await Share.shareXFiles(
          [file],
          text: text,
        );
      } else if (Platform.isIOS) {
        // iOS: 인스타그램 Stories API
        final uri = Uri.parse('instagram-stories://share');
        if (await canLaunchUrl(uri)) {
          return await Share.shareXFiles([file], text: text);
        }
      }
    } catch (e) {
      debugPrint('[SocialShare] 인스타그램 공유 오류: $e');
    }
    
    return await Share.shareXFiles([file], text: text);
  }

  /// 페이스북으로 공유
  static Future<ShareResult> _shareToFacebook(XFile file, String? text) async {
    try {
      return await Share.shareXFiles([file], text: text);
    } catch (e) {
      debugPrint('[SocialShare] 페이스북 공유 오류: $e');
      return await Share.shareXFiles([file], text: text);
    }
  }

  /// X (트위터)로 공유
  static Future<ShareResult> _shareToX(XFile file, String? text) async {
    try {
      return await Share.shareXFiles([file], text: text);
    } catch (e) {
      debugPrint('[SocialShare] X 공유 오류: $e');
      return await Share.shareXFiles([file], text: text);
    }
  }

  /// 공유 플랫폼 선택 다이얼로그 표시
  /// [strings]는 다국어 처리를 위해 선택적으로 전달 가능
  static Future<String?> showShareDialog(BuildContext context, {AppStrings? strings}) async {
    // 플랫폼 이름 다국어 처리
    final localizedPlatforms = strings != null ? [
      SocialPlatform(id: 'share', name: strings.shareOtherApps, icon: Icons.share, color: Colors.blueGrey),
      SocialPlatform(id: 'kakaotalk', name: strings.shareKakaoTalk, icon: Icons.chat_bubble, color: const Color(0xFFFEE500), packageAndroid: 'com.kakao.talk', schemeIOS: 'kakaotalk://'),
      SocialPlatform(id: 'instagram', name: strings.shareInstagram, icon: Icons.camera_alt, color: const Color(0xFFE4405F), packageAndroid: 'com.instagram.android', schemeIOS: 'instagram://'),
      SocialPlatform(id: 'facebook', name: strings.shareFacebook, icon: Icons.facebook, color: const Color(0xFF1877F2), packageAndroid: 'com.facebook.katana', schemeIOS: 'fb://'),
      SocialPlatform(id: 'x', name: strings.shareTwitter, icon: Icons.alternate_email, color: Colors.black, packageAndroid: 'com.twitter.android', schemeIOS: 'twitter://'),
      SocialPlatform(id: 'whatsapp', name: strings.shareWhatsApp, icon: Icons.message, color: const Color(0xFF25D366), packageAndroid: 'com.whatsapp', schemeIOS: 'whatsapp://'),
      SocialPlatform(id: 'telegram', name: strings.shareTelegram, icon: Icons.send, color: const Color(0xFF0088CC), packageAndroid: 'org.telegram.messenger', schemeIOS: 'tg://'),
    ] : platforms;
    
    final shareTitle = strings?.shareTitle ?? '공유하기';
    final cancelLabel = strings?.cancel ?? '취소';
    
    return await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              shareTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: localizedPlatforms.map((platform) {
                return _ShareButton(
                  platform: platform,
                  onTap: () => Navigator.pop(context, platform.id),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SafeArea(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(cancelLabel, style: const TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// MMS로 이미지 발송
  static Future<bool> sendMMS({
    required String imagePath,
    required String phoneNumber,
    String? message,
  }) async {
    try {
      // 전화번호 정규화
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      if (Platform.isAndroid) {
        // Android: Intent로 MMS 발송
        final uri = Uri.parse(
          'sms:$cleanPhone?body=${Uri.encodeComponent(message ?? '')}'
        );
        
        // 이미지 첨부는 share_plus 사용
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: message,
        );
        return true;
      } else if (Platform.isIOS) {
        // iOS: MMS 발송
        final uri = Uri.parse('sms:$cleanPhone');
        if (await canLaunchUrl(uri)) {
          await Share.shareXFiles([XFile(imagePath)], text: message);
          return true;
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('[SocialShare] MMS 발송 오류: $e');
      return false;
    }
  }
}

/// 소셜 플랫폼 정보
class SocialPlatform {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String? packageAndroid;
  final String? schemeIOS;

  const SocialPlatform({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.packageAndroid,
    this.schemeIOS,
  });
}

/// 공유 버튼 위젯
class _ShareButton extends StatelessWidget {
  final SocialPlatform platform;
  final VoidCallback onTap;

  const _ShareButton({
    required this.platform,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: platform.color.withAlpha(30),
              shape: BoxShape.circle,
              border: Border.all(color: platform.color.withAlpha(100), width: 2),
            ),
            child: Icon(
              platform.icon,
              color: platform.id == 'kakaotalk' ? Colors.brown : platform.color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            platform.name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5D4037),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
