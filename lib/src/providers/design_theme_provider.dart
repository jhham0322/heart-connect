import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/design_assets.dart';

/// 디자인 테마 상태 관리 Provider
/// 
/// 앱 전체에서 디자인 테마를 관리하고 변경할 수 있습니다.
class DesignThemeNotifier extends StateNotifier<String> {
  static const String _themeKey = 'design_theme';
  
  DesignThemeNotifier() : super('default') {
    _loadTheme();
  }
  
  /// 저장된 테마 로드
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      if (savedTheme != null && DesignAssets.availableThemes.contains(savedTheme)) {
        state = savedTheme;
        $assets.setTheme(savedTheme);
      }
    } catch (e) {
      // 로드 실패 시 기본값 유지
    }
  }
  
  /// 테마 변경
  Future<void> setTheme(String themeName) async {
    if (DesignAssets.availableThemes.contains(themeName)) {
      state = themeName;
      $assets.setTheme(themeName);
      
      // 저장
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_themeKey, themeName);
      } catch (e) {
        // 저장 실패 무시
      }
    }
  }
  
  /// 다음 테마로 순환
  Future<void> cycleTheme() async {
    final currentIndex = DesignAssets.availableThemes.indexOf(state);
    final nextIndex = (currentIndex + 1) % DesignAssets.availableThemes.length;
    await setTheme(DesignAssets.availableThemes[nextIndex]);
  }
}

/// 현재 디자인 테마 Provider
final designThemeProvider = StateNotifierProvider<DesignThemeNotifier, String>((ref) {
  return DesignThemeNotifier();
});

/// 사용 가능한 테마 목록 Provider
final availableThemesProvider = Provider<List<String>>((ref) {
  return DesignAssets.availableThemes;
});

/// 테마별 이름 맵
const Map<String, String> themeDisplayNames = {
  'default': '기본 디자인',
  'pink_kawaii': '핑크 카와이',
};
