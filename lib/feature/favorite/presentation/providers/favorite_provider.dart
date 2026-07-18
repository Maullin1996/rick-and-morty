import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/providers/auth_provider.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/favorite/presentation/providers/favorite_providers.dart';

class FavoriteNotifier extends Notifier<List<Character>> {
  @override
  List<Character> build() {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    if (!isLoggedIn) return [];

    _loadFavorites();

    return [];
  }

  Future<void> _loadFavorites() async {
    final result = await ref.read(favoriteUseCaseProvider).getFavorites();

    result.fold((_) {}, (favorites) => state = favorites);
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
    ref.read(favoriteUseCaseProvider).addFavorite(character);
  }

  void removeCharacter(int id) {
    state = state.where((c) => c.id != id).toList();
    ref.read(favoriteUseCaseProvider).removeFavorite(id);
  }

  bool isFavorite(int id) {
    return state.any((c) => c.id == id);
  }

  void clearAll() {
    state = [];
  }
}

final favoriteProvider = NotifierProvider<FavoriteNotifier, List<Character>>(
  FavoriteNotifier.new,
);
