import 'package:flutter_test/flutter_test.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';

void main() {
  group('Character Entity', () {
    test('should create a valid Character instance', () {
      final character = Character(
        id: 1,
        name: 'Rick Sanchez',
        gender: 'Male',
        status: 'Alive',
        species: 'Human',
        image: 'https://image.url',
        origin: Origin(name: 'Earth', url: 'https://earth.url'),
        episodes: ['1', '2'],
      );

      expect(character.id, 1);
      expect(character.name, 'Rick Sanchez');
      expect(character.origin.name, 'Earth');
      expect(character.episodes.length, 2);
    });

    test('should support value equality', () {
      final c1 = Character(
        id: 1,
        name: 'Rick',
        gender: 'Male',
        status: 'Alive',
        species: 'Human',
        image: 'url',
        origin: Origin(name: 'Earth', url: 'url'),
        episodes: ['1'],
      );

      final c2 = c1.copyWith();

      expect(c1, equals(c2));
    });

    test('should be created from json', () {
      final json = {
        "id": 1,
        "name": "Rick",
        "gender": "Male",
        "status": "Alive",
        "species": "Human",
        "image": "url",
        "origin": {"name": "Earth", "url": "url"},
        "episodes": ["1", "2"],
      };

      final character = Character.fromJson(json);

      expect(character.id, 1);
      expect(character.origin.name, 'Earth');
    });
  });
}
