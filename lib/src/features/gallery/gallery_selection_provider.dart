import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stores the ID or Path of the currently selected element in the main view.
/// This allows the global Floating Action Button (in ScaffoldWithNav) to know
/// what item is currently being viewed or selected in the child screens.
final currentSelectionProvider = StateProvider<String?>((ref) => null);

/// 현재 보고 있는 갤러리 카테고리 ID (썸네일 목록 동기화용)
final currentCategoryProvider = StateProvider<String?>((ref) => null);

/// 현재 카테고리의 이미지 목록 (파일 경로 리스트)
final currentCategoryImagesProvider = StateProvider<List<String>>((ref) => []);
