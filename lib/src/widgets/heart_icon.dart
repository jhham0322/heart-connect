import 'package:flutter/material.dart';

/// 마음이음 커스텀 하트 아이콘 위젯
/// assets/icons/heart_icon.png 이미지를 사용합니다.
class HeartIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final bool isFilled;

  const HeartIcon({
    super.key,
    this.size = 20,
    this.color,
    this.isFilled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/heart_icon.png',
      width: size,
      height: size,
      color: color,
      colorBlendMode: color != null ? BlendMode.srcIn : null,
      errorBuilder: (context, error, stackTrace) {
        // 이미지 로드 실패 시 기본 하트 아이콘
        return Icon(
          isFilled ? Icons.favorite : Icons.favorite_border,
          size: size,
          color: color ?? const Color(0xFFFF7043),
        );
      },
    );
  }
}
