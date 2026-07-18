import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';

abstract class FavoriteRemoteDatasource {
  Future<List<Character>> getFavorites(String uid);

  Future<void> addFavorite(String uid, Character character);

  Future<void> removeFavorite(String uid, int characterId);
}
