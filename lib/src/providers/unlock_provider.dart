import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 프리미엄 이미지 잠금 해제 상태를 관리하는 Provider
class UnlockProvider extends ChangeNotifier {
  static const String _storageKey = 'unlocked_premium_images';
  
  Set<String> _unlockedImages = {};
  bool _isLoaded = false;

  UnlockProvider() {
    _loadUnlockedImages();
  }

  /// 저장된 잠금 해제 상태 로드
  Future<void> _loadUnlockedImages() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList(_storageKey) ?? [];
    _unlockedImages = saved.toSet();
    _isLoaded = true;
    notifyListeners();
    debugPrint('[UnlockProvider] Loaded ${_unlockedImages.length} unlocked images');
  }

  /// 이미지 잠금 해제 여부 확인
  bool isUnlocked(String categoryId, int index) {
    return _unlockedImages.contains('$categoryId:$index');
  }

  /// 이미지 잠금 해제
  Future<void> unlock(String categoryId, int index) async {
    final key = '$categoryId:$index';
    if (_unlockedImages.contains(key)) return;
    
    _unlockedImages.add(key);
    notifyListeners();
    
    // SharedPreferences에 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _unlockedImages.toList());
    debugPrint('[UnlockProvider] Unlocked: $key');
  }

  /// 특정 카테고리의 해제된 이미지 인덱스 목록
  List<int> getUnlockedIndices(String categoryId) {
    return _unlockedImages
        .where((key) => key.startsWith('$categoryId:'))
        .map((key) => int.parse(key.split(':')[1]))
        .toList();
  }

  /// 로드 완료 여부
  bool get isLoaded => _isLoaded;
}
