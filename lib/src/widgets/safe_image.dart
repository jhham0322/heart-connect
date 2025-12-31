import 'package:flutter/material.dart';

/// 안전한 이미지 위젯
/// 
/// 이미지 로드에 실패해도 UI가 깨지지 않도록 보호합니다.
/// - 이미지가 없으면 placeholder 표시
/// - 크기 제약 적용으로 레이아웃 유지
class SafeImage extends StatelessWidget {
  /// 에셋 이미지 경로
  final String assetPath;
  
  /// 이미지 너비 (null이면 자동)
  final double? width;
  
  /// 이미지 높이 (null이면 자동)
  final double? height;
  
  /// 이미지 맞춤 방식
  final BoxFit fit;
  
  /// 이미지 로드 실패 시 대체 위젯
  final Widget? placeholder;
  
  /// 색상 필터 (틴트)
  final Color? color;
  
  /// 색상 블렌드 모드
  final BlendMode? colorBlendMode;
  
  const SafeImage({
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.color,
    this.colorBlendMode,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      errorBuilder: (context, error, stackTrace) {
        // 이미지 로드 실패 시 placeholder 표시
        return placeholder ?? _buildDefaultPlaceholder();
      },
    );
  }
  
  /// 기본 placeholder 생성
  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey.shade400,
          size: (width != null && height != null) 
              ? (width! < height! ? width! : height!) * 0.4
              : 24,
        ),
      ),
    );
  }
}

/// 네트워크 이미지를 위한 SafeImage 변형
class SafeNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? loadingWidget;
  
  const SafeNetworkImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.loadingWidget,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return loadingWidget ?? Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / 
                  loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return placeholder ?? Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.grey.shade400,
          ),
        );
      },
    );
  }
}
