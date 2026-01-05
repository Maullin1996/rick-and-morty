import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:prueba_tecnica_1/feature/character/data/model/character_model.dart';

import '../../../../../fixtures/fixture_reader.dart';

void main() {
  test('should create model from json', () {
    final jsonMap = jsonDecode(fixture('character.json'));

    final model = CharacterModel.fromJson(jsonMap);

    expect(model.id, 1);
    expect(model.origin.name, 'Earth (C-137)');
  });
  test('should create json from model', () {
    // Arrange
    final model = CharacterModel(
      id: 1,
      name: 'rick',
      status: 'alive',
      species: 'human',
      gender: 'male',
      origin: OriginModel(name: 'earth', url: 'url'),
      image: 'url',
      episode: ['1'],
    );
    final expectedJson = {
      "id": 1,
      "name": "rick",
      "status": "alive",
      "species": "human",
      "gender": "male",
      "origin": {"name": "earth", "url": "url"},
      "image": "url",
      "episode": ["1"],
    };

    //Act
    final json = model.toJson();

    // Assert
    expect(json, equals(expectedJson));
  });
}
