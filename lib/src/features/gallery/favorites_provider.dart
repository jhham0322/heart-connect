import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';

class FavoritesNotifier extends StateNotifier<Set<String>> {
  final AppDatabase _db;

  FavoritesNotifier(this._db) : super({}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final list = await _db.getAllGalleryFavorites();
      state = list.toSet();
      print('[DB] Loaded ${list.length} favorites from SQLite.');
    } catch (e) {
      print('[DB Error] Failed to load favorites: $e');
    }
  }

  Future<void> toggleFavorite(String imagePath) async {
    try {
      if (state.contains(imagePath)) {
        // Remove locally
        state = {...state}..remove(imagePath);
        // Remove from DB
        await _db.removeGalleryFavorite(imagePath);
        print('[DB] Removed favorite: $imagePath');
      } else {
        // Add locally
        state = {...state}..add(imagePath);
        // Add to DB
        await _db.addGalleryFavorite(imagePath);
        print('[DB] Added favorite: $imagePath');
      }
    } catch (e) {
      print('[DB Error] Failed to toggle favorite: $e');
    }
  }

  bool isFavorite(String imagePath) => state.contains(imagePath);
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return FavoritesNotifier(db);
});
