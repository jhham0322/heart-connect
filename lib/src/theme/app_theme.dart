import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors from Design System
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

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentCoral,
        surface: bgColor,
        background: bgColor, // Deprecated in newer Flutter but useful for older
      ),
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.notoSansKr(
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.notoSansKr(
          color: textSecondary,
          fontSize: 14,
        ),
      ),
      iconTheme: const IconThemeData(
        color: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
