import 'dart:convert';

import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  final SharedPreferences _prefs;

  SharedPreferencesService(this._prefs);

  static const String _isFavorite = 'favorites';

  List<Character> getFavorites() {
    final String? favoritesString = _prefs.getString(_isFavorite);
    if (favoritesString == null || favoritesString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> jsonList = json.decode(favoritesString);

      return jsonList
          .map((json) => Character.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveFavorites(List<Character> favorites) async {
    try {
      final List<Map<String, dynamic>> jsonList = favorites
          .map((character) => character.toJson())
          .toList();
      final String jsonString = json.encode(jsonList);

      return await _prefs.setString(_isFavorite, jsonString);
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearFavorites() async {
    return await _prefs.remove(_isFavorite);
  }
}
