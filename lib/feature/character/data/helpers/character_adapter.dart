import 'package:prueba_tecnica_1/feature/character/data/model/character_model.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';

Character characterModelToCharacter(CharacterModel model) {
  return Character(
    id: model.id,
    name: model.name,
    status: model.status,
    species: model.species,
    image: model.image,
    episodes: model.episode,
    gender: model.gender,
    origin: Origin(name: model.origin.name, url: model.origin.url),
  );
}
