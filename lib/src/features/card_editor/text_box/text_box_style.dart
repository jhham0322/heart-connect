import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 글상자 스타일 설정
/// 
/// 글상자의 시각적 스타일(색상, 테두리, 폰트 등)을 관리합니다.
class TextBoxStyle {
  // === 박스 배경 스타일 ===
  final Color backgroundColor;
  final double backgroundOpacity;
  final double borderRadius;
  
  // === 테두리 스타일 ===
  final bool hasBorder;
  final Color borderColor;
  final double borderWidth;
  
  // === 모양 (shape) ===
  final ShapeBorder? shapeBorder; // 원형, 말풍선 등 커스텀 모양
  
  // === 프레임 이미지 ===
  final String? frameImage;
  
  // === 텍스트 스타일 ===
  final String fontFamily;
  final double fontSize;
  final Color textColor;
  final TextAlign textAlign;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  
  // === 세로 글쓰기 ===
  final bool isVertical;
  
  // === 패딩 ===
  final EdgeInsets contentPadding;

  const TextBoxStyle({
    this.backgroundColor = Colors.white,
    this.backgroundOpacity = 0.5,
    this.borderRadius = 12.0,
    this.hasBorder = true,
    this.borderColor = Colors.white,
    this.borderWidth = 1.0,
    this.shapeBorder, // 커스텀 모양 (null이면 기본 RoundedRectangle)
    this.frameImage,
    this.fontFamily = 'Gowun Dodum',
    this.fontSize = 20.0,
    this.textColor = const Color(0xFF1A1A1A),
    this.textAlign = TextAlign.center,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.isVertical = false,
    this.contentPadding = const EdgeInsets.fromLTRB(24, 20, 24, 20),
  });

  /// 기본 스타일
  static const TextBoxStyle defaultStyle = TextBoxStyle();

  /// TextStyle 생성
  TextStyle get textStyle {
    TextStyle style;
    try {
      style = GoogleFonts.getFont(
        fontFamily,
        fontSize: fontSize,
        color: textColor,
        height: 1.4,
      );
    } catch (e) {
      style = TextStyle(
        fontSize: fontSize,
        color: textColor,
        height: 1.4,
      );
    }

    return style.copyWith(
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
    );
  }

  /// BoxDecoration 생성 (shapeBorder 미사용 시)
  BoxDecoration get boxDecoration {
    if (frameImage != null) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        image: DecorationImage(
          image: AssetImage(frameImage!),
          fit: BoxFit.fill,
        ),
      );
    }

    return BoxDecoration(
      color: backgroundColor.withOpacity(backgroundOpacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: hasBorder
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
    );
  }
  
  /// ShapeDecoration 생성 (shapeBorder 사용 시)
  ShapeDecoration get shapeDecoration {
    final shape = shapeBorder ?? RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: hasBorder 
          ? BorderSide(color: borderColor, width: borderWidth)
          : BorderSide.none,
    );
    
    if (frameImage != null) {
      return ShapeDecoration(
        shape: shape,
        image: DecorationImage(
          image: AssetImage(frameImage!),
          fit: BoxFit.fill,
        ),
      );
    }
    
    return ShapeDecoration(
      color: backgroundColor.withOpacity(backgroundOpacity),
      shape: shape,
    );
  }
  
  /// 클리핑용 ShapeBorder (ClipPath에 사용)
  ShapeBorder get clipShape {
    return shapeBorder ?? RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() => {
    'backgroundColor': backgroundColor.value,
    'backgroundOpacity': backgroundOpacity,
    'borderRadius': borderRadius,
    'hasBorder': hasBorder,
    'borderColor': borderColor.value,
    'borderWidth': borderWidth,
    'frameImage': frameImage,
    'fontFamily': fontFamily,
    'fontSize': fontSize,
    'textColor': textColor.value,
    'textAlign': textAlign.name,
    'isBold': isBold,
    'isItalic': isItalic,
    'isUnderline': isUnderline,
    'isVertical': isVertical,
  };

  /// JSON에서 역직렬화
  factory TextBoxStyle.fromJson(Map<String, dynamic> json) {
    return TextBoxStyle(
      backgroundColor: Color(json['backgroundColor'] as int? ?? 0xFFFFFFFF),
      backgroundOpacity: (json['backgroundOpacity'] as num?)?.toDouble() ?? 0.5,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 12.0,
      hasBorder: json['hasBorder'] as bool? ?? true,
      borderColor: Color(json['borderColor'] as int? ?? 0xFFFFFFFF),
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 1.0,
      frameImage: json['frameImage'] as String?,
      fontFamily: json['fontFamily'] as String? ?? 'Gowun Dodum',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 20.0,
      textColor: Color(json['textColor'] as int? ?? 0xFF1A1A1A),
      textAlign: TextAlign.values.firstWhere(
        (e) => e.name == json['textAlign'],
        orElse: () => TextAlign.center,
      ),
      isBold: json['isBold'] as bool? ?? false,
      isItalic: json['isItalic'] as bool? ?? false,
      isUnderline: json['isUnderline'] as bool? ?? false,
      isVertical: json['isVertical'] as bool? ?? false,
    );
  }

  /// 복사본 생성
  TextBoxStyle copyWith({
    Color? backgroundColor,
    double? backgroundOpacity,
    double? borderRadius,
    bool? hasBorder,
    Color? borderColor,
    double? borderWidth,
    String? frameImage,
    String? fontFamily,
    double? fontSize,
    Color? textColor,
    TextAlign? textAlign,
    bool? isBold,
    bool? isItalic,
    bool? isUnderline,
    bool? isVertical,
    EdgeInsets? contentPadding,
  }) {
    return TextBoxStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      borderRadius: borderRadius ?? this.borderRadius,
      hasBorder: hasBorder ?? this.hasBorder,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      frameImage: frameImage ?? this.frameImage,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      textAlign: textAlign ?? this.textAlign,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderline: isUnderline ?? this.isUnderline,
      isVertical: isVertical ?? this.isVertical,
      contentPadding: contentPadding ?? this.contentPadding,
    );
  }
}
