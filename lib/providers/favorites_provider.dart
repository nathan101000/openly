import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  static const _prefsKey = 'favorite_doors';

  final Set<int> _favorites = {};

  Set<int> get favorites => _favorites;

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_prefsKey) ?? [];
    _favorites.addAll(ids.map(int.parse));
    notifyListeners();
  }

  Future<void> toggleFavorite(int doorId) async {
    final prefs = await SharedPreferences.getInstance();
    if (_favorites.contains(doorId)) {
      _favorites.remove(doorId);
    } else {
      _favorites.add(doorId);
    }
    await prefs.setStringList(
      _prefsKey,
      _favorites.map((e) => e.toString()).toList(),
    );
    notifyListeners();
  }

  bool isFavorite(int doorId) => _favorites.contains(doorId);
}
