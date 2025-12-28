import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/design_tokens.dart';

/// 테마 상태 관리 Provider
/// 라이트/다크 테마 전환 및 저장 기능
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }
  
  static const String _themeKey = 'app_theme_mode';
  
  /// 저장된 테마 불러오기
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeName = prefs.getString(_themeKey) ?? 'light';
      
      // 디자인 토큰 로드
      await DesignTokens.instance.loadTheme(themeName);
      
      state = themeName == 'dark' ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      debugPrint('Failed to load theme: $e');
    }
  }
  
  /// 테마 변경
  Future<void> setTheme(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeName = mode == ThemeMode.dark ? 'dark' : 'light';
      
      await prefs.setString(_themeKey, themeName);
      await DesignTokens.instance.loadTheme(themeName);
      
      state = mode;
    } catch (e) {
      debugPrint('Failed to save theme: $e');
    }
  }
  
  /// 테마 토글 (라이트 ↔ 다크)
  Future<void> toggleTheme() async {
    if (state == ThemeMode.light) {
      await setTheme(ThemeMode.dark);
    } else {
      await setTheme(ThemeMode.light);
    }
  }
  
  /// 현재 테마가 다크 모드인지
  bool get isDarkMode => state == ThemeMode.dark;
}

/// 테마 Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// 현재 ThemeData Provider
final themeDataProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeProvider);
  return DesignTokens.instance.toThemeData();
});

/// 디자인 토큰 직접 접근 Provider
final designTokensProvider = Provider<DesignTokens>((ref) {
  ref.watch(themeProvider); // 테마 변경 시 새로고침
  return DesignTokens.instance;
});
