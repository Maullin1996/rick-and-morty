import 'package:prueba_tecnica_1/feature/character/data/model/character_model.dart';

abstract class CharacterRemoteDatasource {
  Future<CharacterModel> getCharacters({required int id});
}
