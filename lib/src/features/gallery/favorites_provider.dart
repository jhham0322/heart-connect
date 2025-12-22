import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super({});

  void toggleFavorite(String imagePath) {
    if (state.contains(imagePath)) {
      state = {...state}..remove(imagePath);
    } else {
      state = {...state}..add(imagePath);
    }
  }

  bool isFavorite(String imagePath) => state.contains(imagePath);
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});
