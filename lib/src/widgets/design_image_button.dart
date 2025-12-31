import 'package:flutter/material.dart';
import 'safe_image.dart';
import '../theme/app_theme.dart';

/// 디자인 이미지 버튼
/// 
/// 이미지 기반의 버튼 위젯입니다.
/// 이미지가 없을 경우 fallback 아이콘을 표시합니다.
class DesignImageButton extends StatelessWidget {
  /// 버튼 이미지 에셋 경로
  final String assetPath;
  
  /// 클릭 이벤트 핸들러
  final VoidCallback? onPressed;
  
  /// 버튼 너비
  final double width;
  
  /// 버튼 높이
  final double height;
  
  /// 이미지 로드 실패 시 대체 아이콘
  final IconData? fallbackIcon;
  
  /// 대체 아이콘 색상
  final Color? fallbackIconColor;
  
  /// 대체 배경 색상
  final Color? fallbackBackgroundColor;
  
  /// 툴팁 텍스트
  final String? tooltip;
  
  /// 활성화 여부
  final bool enabled;
  
  const DesignImageButton({
    required this.assetPath,
    required this.width,
    required this.height,
    this.onPressed,
    this.fallbackIcon,
    this.fallbackIconColor,
    this.fallbackBackgroundColor,
    this.tooltip,
    this.enabled = true,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: SafeImage(
          assetPath: assetPath,
          width: width,
          height: height,
          fit: BoxFit.contain,
          placeholder: _buildFallbackButton(),
        ),
      ),
    );
    
    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    
    return button;
  }
  
  /// 이미지 로드 실패 시 대체 버튼
  Widget _buildFallbackButton() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: fallbackBackgroundColor ?? AppTheme.accentCoral,
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: [
          BoxShadow(
            color: (fallbackBackgroundColor ?? AppTheme.accentCoral).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          fallbackIcon ?? Icons.touch_app,
          color: fallbackIconColor ?? Colors.white,
          size: height * 0.5,
        ),
      ),
    );
  }
}

/// 원형 이미지 버튼
class CircularDesignImageButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback? onPressed;
  final double size;
  final IconData? fallbackIcon;
  final Color? fallbackIconColor;
  final Color? fallbackBackgroundColor;
  final String? tooltip;
  final bool enabled;
  
  const CircularDesignImageButton({
    required this.assetPath,
    required this.size,
    this.onPressed,
    this.fallbackIcon,
    this.fallbackIconColor,
    this.fallbackBackgroundColor,
    this.tooltip,
    this.enabled = true,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return DesignImageButton(
      assetPath: assetPath,
      width: size,
      height: size,
      onPressed: onPressed,
      fallbackIcon: fallbackIcon,
      fallbackIconColor: fallbackIconColor,
      fallbackBackgroundColor: fallbackBackgroundColor,
      tooltip: tooltip,
      enabled: enabled,
    );
  }
}

/// 이미지 텍스트 버튼 (이미지 + 텍스트 조합)
class DesignImageTextButton extends StatelessWidget {
  final String assetPath;
  final String text;
  final VoidCallback? onPressed;
  final double? imageWidth;
  final double? imageHeight;
  final TextStyle? textStyle;
  final IconData? fallbackIcon;
  final MainAxisAlignment alignment;
  final double spacing;
  
  const DesignImageTextButton({
    required this.assetPath,
    required this.text,
    this.onPressed,
    this.imageWidth,
    this.imageHeight,
    this.textStyle,
    this.fallbackIcon,
    this.alignment = MainAxisAlignment.center,
    this.spacing = 8,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisAlignment: alignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          SafeImage(
            assetPath: assetPath,
            width: imageWidth ?? 24,
            height: imageHeight ?? 24,
            placeholder: Icon(
              fallbackIcon ?? Icons.image,
              size: imageWidth ?? 24,
            ),
          ),
          SizedBox(width: spacing),
          Text(
            text,
            style: textStyle ?? const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
