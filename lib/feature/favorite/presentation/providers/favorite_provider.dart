import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/core/services/shared_preferences_service.dart';
import 'package:prueba_tecnica_1/core/services/shared_preferences_services_provider.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';

class FavoriteNotifier extends Notifier<List<Character>> {
  late final SharedPreferencesService _favoritesService;

  @override
  List<Character> build() {
    _favoritesService = ref.read(sharedPreferencesServiceProvider);

    return _favoritesService.getFavorites();
  }

  void toggleCharacter(Character character) {
    final exists = state.any((c) => c.id == character.id);

    if (exists) {
      removeCharacter(character.id);
    } else {
      addCharacter(character);
    }
  }

  void addCharacter(Character character) {
    state = [character, ...state];
    _saveFavorites();
  }

  void removeCharacter(int id) {
    state = state.where((c) => c.id != id).toList();
    _saveFavorites();
  }

  bool isFavorite(int id) {
    return state.any((c) => c.id == id);
  }

  void clearAll() {
    state = [];
    _favoritesService.clearFavorites();
  }

  void _saveFavorites() {
    _favoritesService.saveFavorites(state);
  }
}

final favoriteProvider = NotifierProvider<FavoriteNotifier, List<Character>>(
  FavoriteNotifier.new,
);
