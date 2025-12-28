import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_tokens.dart';

/// 앱 테마 - DesignTokens 기반
/// 하위 호환성을 위해 기존 상수 유지
class AppTheme {
  // ===== Legacy Constants (하위 호환성) =====
  // 기존 코드에서 AppTheme.xxx로 접근하는 것 지원
  static Color get bgColor => $tokens.bgPrimary;
  static Color get textPrimary => $tokens.textPrimary;
  static Color get textSecondary => $tokens.textSecondary;
  static Color get accentCoral => $tokens.primaryMain;
  static Color get accentCoralLight => $tokens.primaryLight;
  static Color get accentYellow => $tokens.secondaryMain;
  static Color get cardBg => $tokens.bgSecondary;
  static Color get white => Colors.white;
  static Color get grayLight => $tokens.borderLight;
  static Color get grayBtn => $tokens.borderMedium;

  /// 라이트 테마 생성
  static ThemeData get lightTheme {
    // DesignTokens가 로드되어 있으면 그것을 사용
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: $tokens.bgPrimary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: $tokens.primaryMain,
        surface: $tokens.bgPrimary,
        primary: $tokens.primaryMain,
        secondary: $tokens.secondaryMain,
        error: $tokens.statusError,
      ),
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(
          color: $tokens.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.notoSansKr(
          color: $tokens.textPrimary,
          fontSize: $tokens.fontSizeLg,
        ),
        bodyMedium: GoogleFonts.notoSansKr(
          color: $tokens.textSecondary,
          fontSize: $tokens.fontSizeMd,
        ),
      ),
      iconTheme: IconThemeData(
        color: $tokens.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: $tokens.textPrimary),
        titleTextStyle: TextStyle(
          color: $tokens.textPrimary,
          fontSize: $tokens.fontSizeXl,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: $tokens.primaryButtonStyle,
      ),
      cardTheme: CardTheme(
        color: $tokens.bgCard,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: $tokens.borderRadiusXl),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: $tokens.bgDialog,
        shape: RoundedRectangleBorder(borderRadius: $tokens.borderRadius2xl),
      ),
    );
  }

  /// 다크 테마 생성
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: $tokens.bgPrimary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: $tokens.primaryMain,
        brightness: Brightness.dark,
        surface: $tokens.bgPrimary,
        primary: $tokens.primaryMain,
        secondary: $tokens.secondaryMain,
        error: $tokens.statusError,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.nunito(
          color: $tokens.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.notoSansKr(
          color: $tokens.textPrimary,
          fontSize: $tokens.fontSizeLg,
        ),
        bodyMedium: GoogleFonts.notoSansKr(
          color: $tokens.textSecondary,
          fontSize: $tokens.fontSizeMd,
        ),
      ),
      iconTheme: IconThemeData(
        color: $tokens.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: $tokens.textPrimary),
        titleTextStyle: TextStyle(
          color: $tokens.textPrimary,
          fontSize: $tokens.fontSizeXl,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: $tokens.primaryButtonStyle,
      ),
      cardTheme: CardTheme(
        color: $tokens.bgCard,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: $tokens.borderRadiusXl),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: $tokens.bgDialog,
        shape: RoundedRectangleBorder(borderRadius: $tokens.borderRadius2xl),
      ),
    );
  }
}
