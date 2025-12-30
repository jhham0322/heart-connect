import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:heart_connect/src/l10n/app_strings.dart';

/// ?뚯뀥 誘몃뵒??怨듭쑀 ?쒕퉬??
class SocialShareService {
  
  /// 吏?먰븯???뚯뀥 誘몃뵒???뚮옯??
  static const List<SocialPlatform> platforms = [
    SocialPlatform(
      id: 'share',
      name: '湲고? ?깆쑝濡?怨듭쑀',
      icon: Icons.share,
      color: Colors.blueGrey,
    ),
    SocialPlatform(
      id: 'kakaotalk',
      name: '移댁뭅?ㅽ넚',
      icon: Icons.chat_bubble,
      color: Color(0xFFFEE500),
      packageAndroid: 'com.kakao.talk',
      schemeIOS: 'kakaotalk://',
    ),
    SocialPlatform(
      id: 'instagram',
      name: '?몄뒪?洹몃옩',
      icon: Icons.camera_alt,
      color: Color(0xFFE4405F),
      packageAndroid: 'com.instagram.android',
      schemeIOS: 'instagram://',
    ),
    SocialPlatform(
      id: 'facebook',
      name: '?섏씠?ㅻ턿',
      icon: Icons.facebook,
      color: Color(0xFF1877F2),
      packageAndroid: 'com.facebook.katana',
      schemeIOS: 'fb://',
    ),
    SocialPlatform(
      id: 'x',
      name: 'X (?몄쐞??',
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
      name: '?붾젅洹몃옩',
      icon: Icons.send,
      color: Color(0xFF0088CC),
      packageAndroid: 'org.telegram.messenger',
      schemeIOS: 'tg://',
    ),
  ];

  /// ?대?吏瑜??뱀젙 ?뚮옯?쇱쑝濡?怨듭쑀
  static Future<ShareResult> shareImage({
    required String imagePath,
    required String platformId,
    String? text,
  }) async {
    final file = XFile(imagePath);
    
    if (platformId == 'share') {
      // 湲곕낯 怨듭쑀 (?ъ슜?먭? ???좏깮)
      return await Share.shareXFiles(
        [file],
        text: text ?? '留덉쓬???꾪빀?덈떎 ?뮑',
        subject: 'Heart-Connect 移대뱶',
      );
    }
    
    // ?뱀젙 ?뚮옯?쇱쑝濡?怨듭쑀
    final platform = platforms.firstWhere(
      (p) => p.id == platformId,
      orElse: () => platforms.first,
    );
    
    // ?뚮옯?쇰퀎 怨듭쑀 ?쒕룄
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
        // 湲곕낯 怨듭쑀濡?fallback
        return await Share.shareXFiles([file], text: text);
    }
  }

  /// 移댁뭅?ㅽ넚?쇰줈 怨듭쑀
  static Future<ShareResult> _shareToKakao(XFile file, String? text) async {
    try {
      if (Platform.isAndroid) {
        // Android: 移댁뭅?ㅽ넚 ?깆쑝濡?吏곸젒 怨듭쑀
        return await Share.shareXFiles(
          [file],
          text: text ?? '留덉쓬???꾪빀?덈떎 ?뮑',
        );
      } else if (Platform.isIOS) {
        // iOS: 移댁뭅?ㅽ넚 URL Scheme ?ъ슜
        final uri = Uri.parse('kakaotalk://');
        if (await canLaunchUrl(uri)) {
          return await Share.shareXFiles([file], text: text);
        }
      }
    } catch (e) {
      
    }
    
    // Fallback: 湲곕낯 怨듭쑀
    return await Share.shareXFiles([file], text: text);
  }

  /// ?몄뒪?洹몃옩?쇰줈 怨듭쑀 (Stories)
  static Future<ShareResult> _shareToInstagram(XFile file, String? text) async {
    try {
      if (Platform.isAndroid) {
        // Android: ?몄뒪?洹몃옩 ?ㅽ넗由щ줈 怨듭쑀
        return await Share.shareXFiles(
          [file],
          text: text,
        );
      } else if (Platform.isIOS) {
        // iOS: ?몄뒪?洹몃옩 Stories API
        final uri = Uri.parse('instagram-stories://share');
        if (await canLaunchUrl(uri)) {
          return await Share.shareXFiles([file], text: text);
        }
      }
    } catch (e) {
      
    }
    
    return await Share.shareXFiles([file], text: text);
  }

  /// ?섏씠?ㅻ턿?쇰줈 怨듭쑀
  static Future<ShareResult> _shareToFacebook(XFile file, String? text) async {
    try {
      return await Share.shareXFiles([file], text: text);
    } catch (e) {
      
      return await Share.shareXFiles([file], text: text);
    }
  }

  /// X (?몄쐞??濡?怨듭쑀
  static Future<ShareResult> _shareToX(XFile file, String? text) async {
    try {
      return await Share.shareXFiles([file], text: text);
    } catch (e) {
      
      return await Share.shareXFiles([file], text: text);
    }
  }

  /// 怨듭쑀 ?뚮옯???좏깮 ?ㅼ씠?쇰줈洹??쒖떆
  /// [strings]???ㅺ뎅??泥섎━瑜??꾪빐 ?좏깮?곸쑝濡??꾨떖 媛??
  static Future<String?> showShareDialog(BuildContext context, {AppStrings? strings}) async {
    // ?뚮옯???대쫫 ?ㅺ뎅??泥섎━
    final localizedPlatforms = strings != null ? [
      SocialPlatform(id: 'share', name: strings.shareOtherApps, icon: Icons.share, color: Colors.blueGrey),
      SocialPlatform(id: 'kakaotalk', name: strings.shareKakaoTalk, icon: Icons.chat_bubble, color: const Color(0xFFFEE500), packageAndroid: 'com.kakao.talk', schemeIOS: 'kakaotalk://'),
      SocialPlatform(id: 'instagram', name: strings.shareInstagram, icon: Icons.camera_alt, color: const Color(0xFFE4405F), packageAndroid: 'com.instagram.android', schemeIOS: 'instagram://'),
      SocialPlatform(id: 'facebook', name: strings.shareFacebook, icon: Icons.facebook, color: const Color(0xFF1877F2), packageAndroid: 'com.facebook.katana', schemeIOS: 'fb://'),
      SocialPlatform(id: 'x', name: strings.shareTwitter, icon: Icons.alternate_email, color: Colors.black, packageAndroid: 'com.twitter.android', schemeIOS: 'twitter://'),
      SocialPlatform(id: 'whatsapp', name: strings.shareWhatsApp, icon: Icons.message, color: const Color(0xFF25D366), packageAndroid: 'com.whatsapp', schemeIOS: 'whatsapp://'),
      SocialPlatform(id: 'telegram', name: strings.shareTelegram, icon: Icons.send, color: const Color(0xFF0088CC), packageAndroid: 'org.telegram.messenger', schemeIOS: 'tg://'),
    ] : platforms;
    
    final shareTitle = strings?.shareTitle ?? '怨듭쑀?섍린';
    final cancelLabel = strings?.cancel ?? '痍⑥냼';
    
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

  /// MMS濡??대?吏 諛쒖넚
  static Future<bool> sendMMS({
    required String imagePath,
    required String phoneNumber,
    String? message,
  }) async {
    try {
      // ?꾪솕踰덊샇 ?뺢퇋??
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      if (Platform.isAndroid) {
        // Android: Intent濡?MMS 諛쒖넚
        final uri = Uri.parse(
          'sms:$cleanPhone?body=${Uri.encodeComponent(message ?? '')}'
        );
        
        // ?대?吏 泥⑤???share_plus ?ъ슜
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: message,
        );
        return true;
      } else if (Platform.isIOS) {
        // iOS: MMS 諛쒖넚
        final uri = Uri.parse('sms:$cleanPhone');
        if (await canLaunchUrl(uri)) {
          await Share.shareXFiles([XFile(imagePath)], text: message);
          return true;
        }
      }
      
      return false;
    } catch (e) {
      
      return false;
    }
  }
}

/// ?뚯뀥 ?뚮옯???뺣낫
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

/// 怨듭쑀 踰꾪듉 ?꾩젽
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

