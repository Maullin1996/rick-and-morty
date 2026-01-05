import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:prueba_tecnica_1/core/services/shared_preferences_service.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late SharedPreferencesService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  test(
    'getFavorites should return empty list when no data is stored',
    () async {
      //Arrange
      prefs = await SharedPreferences.getInstance();
      service = SharedPreferencesService(prefs);
      //Act
      final result = service.getFavorites();

      //Assert
      expect(result, isEmpty);
    },
  );
  test('getFavorites should return elements when data is stored', () async {
    // Arrange
    prefs = await SharedPreferences.getInstance();
    service = SharedPreferencesService(prefs);
    final character = Character(
      id: 1,
      name: 'morty',
      gender: 'male',
      status: 'alive',
      species: 'human',
      image: 'url',
      origin: Origin(name: 'Earth', url: 'url'),
      episodes: ['1'],
    );

    //Act
    final saved = await service.saveFavorites([character]);
    final result = service.getFavorites();

    // Assert
    expect(saved, true);
    expect(result.length, 1);
    expect(result.first.id, 1);
  });
  test('clearFavorites should clear elements when is called', () async {
    // Arrange
    prefs = await SharedPreferences.getInstance();
    service = SharedPreferencesService(prefs);
    final character = Character(
      id: 1,
      name: 'morty',
      gender: 'male',
      status: 'alive',
      species: 'human',
      image: 'url',
      origin: Origin(name: 'Earth', url: 'url'),
      episodes: ['1'],
    );

    //Act
    final saved = await service.saveFavorites([character]);
    final result = service.getFavorites();

    // Assert
    expect(saved, true);
    expect(result.length, 1);
    expect(result.first.id, 1);

    //Act
    final clear = await service.clearFavorites();
    final result2 = service.getFavorites();

    //Assert
    expect(clear, true);
    expect(result2, isEmpty);
  });

  test('getFavorites should return list when stored JSON is valid', () async {
    final characterJson = [
      {
        "id": 1,
        "name": "morty",
        "gender": "male",
        "status": "alive",
        "species": "human",
        "image": "url",
        "origin": {"name": "Earth", "url": "url"},
        "episodes": ["1"],
      },
    ];

    SharedPreferences.setMockInitialValues({
      'favorites': json.encode(characterJson),
    });

    final prefs = await SharedPreferences.getInstance();
    final service = SharedPreferencesService(prefs);

    final result = service.getFavorites();

    expect(result, isNotEmpty);
    expect(result.length, 1);
    expect(result.first.id, 1);
    expect(result.first.name, 'morty');
  });

  test(
    'getFavorites should return empty list when stored JSON is corrupt',
    () async {
      SharedPreferences.setMockInitialValues({
        'favorites': json.encode('{invalid-json'),
      });

      final prefs = await SharedPreferences.getInstance();
      final service = SharedPreferencesService(prefs);

      final result = service.getFavorites();

      expect(result, isEmpty);
    },
  );
}
