import 'package:prueba_tecnica_1/core/services/shared_preferences_service.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';

class FakeSharedPreferencesService implements SharedPreferencesService {
  List<Character> _storage = [];
  @override
  Future<bool> clearFavorites() async {
    _storage = [];
    return true;
  }

  @override
  List<Character> getFavorites() {
    return _storage;
  }

  @override
  Future<bool> saveFavorites(List<Character> favorites) async {
    _storage = List.from(favorites);
    return true;
  }
}
