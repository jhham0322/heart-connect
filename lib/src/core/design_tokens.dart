import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 디자인 토큰 시스템
/// JSON 파일에서 디자인 토큰을 로드하여 앱 전체에서 사용
/// 디자이너가 JSON 파일만 수정하면 앱 디자인이 변경됨
class DesignTokens {
  static DesignTokens? _instance;
  static DesignTokens get instance => _instance ?? DesignTokens._();
  
  DesignTokens._();
  
  Map<String, dynamic> _tokens = {};
  String _currentTheme = 'light';
  
  /// 테마 로드 (assets/themes/light_theme.json 또는 dark_theme.json)
  Future<void> loadTheme(String themeName) async {
    try {
      final jsonString = await rootBundle.loadString('assets/themes/${themeName}_theme.json');
      _tokens = json.decode(jsonString);
      _currentTheme = themeName;
      _instance = this;
    } catch (e) {
      debugPrint('Failed to load theme: $e');
      // 기본값 사용
      _tokens = _getDefaultTokens();
    }
  }
  
  String get currentTheme => _currentTheme;
  
  // ============== Colors ==============
  
  /// Primary 색상 팔레트
  Color get primaryMain => _parseColor(_tokens['colors']?['primary']?['main']) ?? const Color(0xFFFF8A65);
  Color get primaryLight => _parseColor(_tokens['colors']?['primary']?['light']) ?? const Color(0xFFFFAB91);
  Color get primaryDark => _parseColor(_tokens['colors']?['primary']?['dark']) ?? const Color(0xFFE64A19);
  Color get primaryContrast => _parseColor(_tokens['colors']?['primary']?['contrast']) ?? Colors.white;
  
  /// Secondary 색상 팔레트
  Color get secondaryMain => _parseColor(_tokens['colors']?['secondary']?['main']) ?? const Color(0xFFFDD835);
  Color get secondaryLight => _parseColor(_tokens['colors']?['secondary']?['light']) ?? const Color(0xFFFFEE58);
  Color get secondaryDark => _parseColor(_tokens['colors']?['secondary']?['dark']) ?? const Color(0xFFF9A825);
  
  /// Background 색상
  Color get bgPrimary => _parseColor(_tokens['colors']?['background']?['primary']) ?? const Color(0xFFFFFCF9);
  Color get bgSecondary => _parseColor(_tokens['colors']?['background']?['secondary']) ?? const Color(0xFFFFF8E1);
  Color get bgCard => _parseColor(_tokens['colors']?['background']?['card']) ?? Colors.white;
  Color get bgDialog => _parseColor(_tokens['colors']?['background']?['dialog']) ?? Colors.white;
  
  /// Text 색상
  Color get textPrimary => _parseColor(_tokens['colors']?['text']?['primary']) ?? const Color(0xFF5D4037);
  Color get textSecondary => _parseColor(_tokens['colors']?['text']?['secondary']) ?? const Color(0xFF8D6E63);
  Color get textHint => _parseColor(_tokens['colors']?['text']?['hint']) ?? const Color(0xFFBCAAA4);
  Color get textDisabled => _parseColor(_tokens['colors']?['text']?['disabled']) ?? const Color(0xFFD7CCC8);
  Color get textInverse => _parseColor(_tokens['colors']?['text']?['inverse']) ?? Colors.white;
  
  /// Border 색상
  Color get borderLight => _parseColor(_tokens['colors']?['border']?['light']) ?? const Color(0xFFF5F5F5);
  Color get borderMedium => _parseColor(_tokens['colors']?['border']?['medium']) ?? const Color(0xFFE0E0E0);
  Color get borderDark => _parseColor(_tokens['colors']?['border']?['dark']) ?? const Color(0xFFBDBDBD);
  
  /// Status 색상
  Color get statusSuccess => _parseColor(_tokens['colors']?['status']?['success']) ?? const Color(0xFF4CAF50);
  Color get statusWarning => _parseColor(_tokens['colors']?['status']?['warning']) ?? const Color(0xFFFF9800);
  Color get statusError => _parseColor(_tokens['colors']?['status']?['error']) ?? const Color(0xFFE53935);
  Color get statusInfo => _parseColor(_tokens['colors']?['status']?['info']) ?? const Color(0xFF2196F3);
  
  /// Surface 색상
  Color get surfaceElevated => _parseColor(_tokens['colors']?['surface']?['elevated']) ?? Colors.white;
  Color get surfaceOverlay => _parseColor(_tokens['colors']?['surface']?['overlay']) ?? Colors.black54;
  
  // ============== Typography ==============
  
  String get fontPrimary => _tokens['typography']?['fontFamily']?['primary'] ?? 'Nunito';
  String get fontSecondary => _tokens['typography']?['fontFamily']?['secondary'] ?? 'Noto Sans KR';
  String get fontDisplay => _tokens['typography']?['fontFamily']?['display'] ?? 'Great Vibes';
  
  double get fontSizeXs => (_tokens['typography']?['fontSize']?['xs'] ?? 10).toDouble();
  double get fontSizeSm => (_tokens['typography']?['fontSize']?['sm'] ?? 12).toDouble();
  double get fontSizeMd => (_tokens['typography']?['fontSize']?['md'] ?? 14).toDouble();
  double get fontSizeLg => (_tokens['typography']?['fontSize']?['lg'] ?? 16).toDouble();
  double get fontSizeXl => (_tokens['typography']?['fontSize']?['xl'] ?? 20).toDouble();
  double get fontSize2xl => (_tokens['typography']?['fontSize']?['2xl'] ?? 24).toDouble();
  double get fontSize3xl => (_tokens['typography']?['fontSize']?['3xl'] ?? 32).toDouble();
  double get fontSize4xl => (_tokens['typography']?['fontSize']?['4xl'] ?? 40).toDouble();
  
  // ============== Spacing ==============
  
  double get spaceNone => 0;
  double get spaceXs => (_tokens['spacing']?['xs'] ?? 4).toDouble();
  double get spaceSm => (_tokens['spacing']?['sm'] ?? 8).toDouble();
  double get spaceMd => (_tokens['spacing']?['md'] ?? 16).toDouble();
  double get spaceLg => (_tokens['spacing']?['lg'] ?? 24).toDouble();
  double get spaceXl => (_tokens['spacing']?['xl'] ?? 32).toDouble();
  double get space2xl => (_tokens['spacing']?['2xl'] ?? 48).toDouble();
  double get space3xl => (_tokens['spacing']?['3xl'] ?? 64).toDouble();
  
  // ============== Border Radius ==============
  
  double get radiusNone => 0;
  double get radiusSm => (_tokens['borderRadius']?['sm'] ?? 4).toDouble();
  double get radiusMd => (_tokens['borderRadius']?['md'] ?? 8).toDouble();
  double get radiusLg => (_tokens['borderRadius']?['lg'] ?? 12).toDouble();
  double get radiusXl => (_tokens['borderRadius']?['xl'] ?? 16).toDouble();
  double get radius2xl => (_tokens['borderRadius']?['2xl'] ?? 24).toDouble();
  double get radiusFull => (_tokens['borderRadius']?['full'] ?? 9999).toDouble();
  
  BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  BorderRadius get borderRadius2xl => BorderRadius.circular(radius2xl);
  
  // ============== Shadows ==============
  
  BoxShadow get shadowSm => _parseShadow(_tokens['shadows']?['sm']);
  BoxShadow get shadowMd => _parseShadow(_tokens['shadows']?['md']);
  BoxShadow get shadowLg => _parseShadow(_tokens['shadows']?['lg']);
  BoxShadow get shadowXl => _parseShadow(_tokens['shadows']?['xl']);
  
  List<BoxShadow> get cardShadow => [shadowMd];
  List<BoxShadow> get dialogShadow => [shadowXl];
  
  // ============== Animation ==============
  
  Duration get animationFast => Duration(milliseconds: _tokens['animation']?['duration']?['fast'] ?? 150);
  Duration get animationNormal => Duration(milliseconds: _tokens['animation']?['duration']?['normal'] ?? 300);
  Duration get animationSlow => Duration(milliseconds: _tokens['animation']?['duration']?['slow'] ?? 500);
  
  // ============== Component Styles ==============
  
  /// Primary Button 스타일
  ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryMain,
    foregroundColor: primaryContrast,
    padding: EdgeInsets.symmetric(horizontal: spaceLg, vertical: spaceMd),
    shape: RoundedRectangleBorder(borderRadius: borderRadiusLg),
    elevation: 4,
  );
  
  /// Secondary Button 스타일
  ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: primaryMain,
    side: BorderSide(color: primaryMain),
    padding: EdgeInsets.symmetric(horizontal: spaceLg, vertical: spaceMd),
    shape: RoundedRectangleBorder(borderRadius: borderRadiusLg),
  );
  
  /// Ghost Button 스타일
  ButtonStyle get ghostButtonStyle => TextButton.styleFrom(
    foregroundColor: textPrimary,
    padding: EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceSm),
    shape: RoundedRectangleBorder(borderRadius: borderRadiusMd),
  );
  
  /// Card Decoration
  BoxDecoration get cardDecoration => BoxDecoration(
    color: bgCard,
    borderRadius: borderRadiusXl,
    boxShadow: cardShadow,
  );
  
  /// Dialog Decoration
  BoxDecoration get dialogDecoration => BoxDecoration(
    color: bgDialog,
    borderRadius: borderRadius2xl,
    boxShadow: dialogShadow,
  );
  
  /// Input Decoration
  InputDecoration inputDecoration({String? hintText, Widget? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: textHint),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: bgSecondary,
      border: OutlineInputBorder(
        borderRadius: borderRadiusMd,
        borderSide: BorderSide(color: borderMedium),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadiusMd,
        borderSide: BorderSide(color: borderMedium),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadiusMd,
        borderSide: BorderSide(color: primaryMain, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceSm),
    );
  }
  
  // ============== Text Styles ==============
  
  TextStyle get headline1 => TextStyle(
    fontFamily: fontPrimary,
    fontSize: fontSize3xl,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  TextStyle get headline2 => TextStyle(
    fontFamily: fontPrimary,
    fontSize: fontSize2xl,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  TextStyle get headline3 => TextStyle(
    fontFamily: fontPrimary,
    fontSize: fontSizeXl,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  TextStyle get body1 => TextStyle(
    fontFamily: fontSecondary,
    fontSize: fontSizeLg,
    color: textPrimary,
  );
  
  TextStyle get body2 => TextStyle(
    fontFamily: fontSecondary,
    fontSize: fontSizeMd,
    color: textSecondary,
  );
  
  TextStyle get caption => TextStyle(
    fontFamily: fontSecondary,
    fontSize: fontSizeSm,
    color: textHint,
  );
  
  TextStyle get button => TextStyle(
    fontFamily: fontPrimary,
    fontSize: fontSizeMd,
    fontWeight: FontWeight.w600,
  );
  
  // ============== ThemeData 생성 ==============
  
  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgPrimary,
      colorScheme: ColorScheme(
        brightness: _currentTheme == 'dark' ? Brightness.dark : Brightness.light,
        primary: primaryMain,
        onPrimary: primaryContrast,
        secondary: secondaryMain,
        onSecondary: Colors.black,
        error: statusError,
        onError: Colors.white,
        surface: bgCard,
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: headline3,
      ),
      cardTheme: CardTheme(
        color: bgCard,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: borderRadiusXl),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButtonStyle),
      textButtonTheme: TextButtonThemeData(style: ghostButtonStyle),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgSecondary,
        border: OutlineInputBorder(borderRadius: borderRadiusMd),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: bgDialog,
        shape: RoundedRectangleBorder(borderRadius: borderRadius2xl),
      ),
    );
  }
  
  // ============== Helper Methods ==============
  
  Color? _parseColor(dynamic value) {
    if (value == null) return null;
    
    String colorStr = value.toString();
    
    // rgba 형식 처리: rgba(0, 0, 0, 0.5)
    if (colorStr.startsWith('rgba')) {
      final match = RegExp(r'rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\)').firstMatch(colorStr);
      if (match != null) {
        return Color.fromRGBO(
          int.parse(match.group(1)!),
          int.parse(match.group(2)!),
          int.parse(match.group(3)!),
          double.parse(match.group(4)!),
        );
      }
    }
    
    // Hex 형식 처리: #FF8A65
    if (colorStr.startsWith('#')) {
      colorStr = colorStr.substring(1);
      if (colorStr.length == 6) {
        return Color(int.parse('FF$colorStr', radix: 16));
      } else if (colorStr.length == 8) {
        return Color(int.parse(colorStr, radix: 16));
      }
    }
    
    return null;
  }
  
  BoxShadow _parseShadow(Map<String, dynamic>? shadow) {
    if (shadow == null) {
      return const BoxShadow(color: Colors.transparent);
    }
    
    return BoxShadow(
      offset: Offset(
        (shadow['offsetX'] ?? 0).toDouble(),
        (shadow['offsetY'] ?? 0).toDouble(),
      ),
      blurRadius: (shadow['blur'] ?? 0).toDouble(),
      spreadRadius: (shadow['spread'] ?? 0).toDouble(),
      color: _parseColor(shadow['color']) ?? Colors.black12,
    );
  }
  
  Map<String, dynamic> _getDefaultTokens() {
    return {
      'colors': {
        'primary': {'main': '#FF8A65', 'light': '#FFAB91', 'dark': '#E64A19', 'contrast': '#FFFFFF'},
        'secondary': {'main': '#FDD835', 'light': '#FFEE58', 'dark': '#F9A825'},
        'background': {'primary': '#FFFCF9', 'secondary': '#FFF8E1', 'card': '#FFFFFF', 'dialog': '#FFFFFF'},
        'text': {'primary': '#5D4037', 'secondary': '#8D6E63', 'hint': '#BCAAA4', 'disabled': '#D7CCC8', 'inverse': '#FFFFFF'},
        'border': {'light': '#F5F5F5', 'medium': '#E0E0E0', 'dark': '#BDBDBD'},
        'status': {'success': '#4CAF50', 'warning': '#FF9800', 'error': '#E53935', 'info': '#2196F3'},
        'surface': {'elevated': '#FFFFFF', 'overlay': 'rgba(0, 0, 0, 0.5)'},
      },
      'typography': {
        'fontFamily': {'primary': 'Nunito', 'secondary': 'Noto Sans KR', 'display': 'Great Vibes'},
        'fontSize': {'xs': 10, 'sm': 12, 'md': 14, 'lg': 16, 'xl': 20, '2xl': 24, '3xl': 32, '4xl': 40},
      },
      'spacing': {'xs': 4, 'sm': 8, 'md': 16, 'lg': 24, 'xl': 32, '2xl': 48, '3xl': 64},
      'borderRadius': {'sm': 4, 'md': 8, 'lg': 12, 'xl': 16, '2xl': 24, 'full': 9999},
      'shadows': {
        'sm': {'offsetX': 0, 'offsetY': 1, 'blur': 3, 'spread': 0, 'color': 'rgba(0, 0, 0, 0.1)'},
        'md': {'offsetX': 0, 'offsetY': 4, 'blur': 6, 'spread': -1, 'color': 'rgba(0, 0, 0, 0.1)'},
        'lg': {'offsetX': 0, 'offsetY': 10, 'blur': 15, 'spread': -3, 'color': 'rgba(0, 0, 0, 0.1)'},
        'xl': {'offsetX': 0, 'offsetY': 20, 'blur': 25, 'spread': -5, 'color': 'rgba(0, 0, 0, 0.15)'},
      },
      'animation': {'duration': {'fast': 150, 'normal': 300, 'slow': 500}},
    };
  }
}

/// 편의를 위한 글로벌 접근자
DesignTokens get $tokens => DesignTokens.instance;
