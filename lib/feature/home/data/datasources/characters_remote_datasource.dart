import 'package:prueba_tecnica_1/feature/character/data/model/character_model.dart';

abstract class CharactersRemoteDatasource {
  Future<List<CharacterModel>> getCharacters({
    int page = 1,
    String? status,
    String? name,
  });
}
