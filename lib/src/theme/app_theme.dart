import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_tokens.dart';

/// 앱 테마 - DesignTokens 기반
/// 하위 호환성을 위해 기존 상수 유지 (const 표현식에서 사용 가능)
class AppTheme {
  // ===== Static Constants (const 표현식 호환) =====
  // 기존 코드에서 const Icon(color: AppTheme.textPrimary) 등 사용 가능
  static const Color bgColor = Color(0xFFFFFCF9);
  static const Color textPrimary = Color(0xFF5D4037);
  static const Color textSecondary = Color(0xFF8D6E63);
  static const Color accentCoral = Color(0xFFFF8A65);
  static const Color accentCoralLight = Color(0xFFFFF1EB);
  static const Color accentYellow = Color(0xFFFDD835);
  static const Color cardBg = Color(0xFFFFF8E1);
  static const Color white = Colors.white;
  static const Color grayLight = Color(0xFFF5F5F5);
  static const Color grayBtn = Color(0xFFE0E0E0);

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
      cardTheme: CardThemeData(
        color: $tokens.bgCard,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: $tokens.borderRadiusXl),
      ),
      dialogTheme: DialogThemeData(
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
      cardTheme: CardThemeData(
        color: $tokens.bgCard,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: $tokens.borderRadiusXl),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: $tokens.bgDialog,
        shape: RoundedRectangleBorder(borderRadius: $tokens.borderRadius2xl),
      ),
    );
  }
}
