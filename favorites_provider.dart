import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<FavoriteCity> _favorites = [];
  bool _isLoaded = false;

  List<FavoriteCity> get favorites => List.unmodifiable(_favorites);
  int get count => _favorites.length;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    if (_isLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(AppConstants.favoritesKey);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List;
        _favorites.addAll(
          list.map((e) => FavoriteCity.fromJson(e as Map<String, dynamic>)),
        );
      } catch (_) {}
    }
    _isLoaded = true;
    notifyListeners();
  }

  bool isFavorite(String cityName, String country) {
    return _favorites.any(
      (f) => f.cityName == cityName && f.country == country,
    );
  }

  Future<void> addFavorite(FavoriteCity city) async {
    if (!isFavorite(city.cityName, city.country)) {
      _favorites.add(city);
      await _save();
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String cityName, String country) async {
    _favorites.removeWhere(
      (f) => f.cityName == cityName && f.country == country,
    );
    await _save();
    notifyListeners();
  }

  Future<void> toggleFavorite(FavoriteCity city) async {
    if (isFavorite(city.cityName, city.country)) {
      await removeFavorite(city.cityName, city.country);
    } else {
      await addFavorite(city);
    }
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final item = _favorites.removeAt(oldIndex);
    _favorites.insert(newIndex, item);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_favorites.map((f) => f.toJson()).toList());
    await prefs.setString(AppConstants.favoritesKey, json);
  }
}
