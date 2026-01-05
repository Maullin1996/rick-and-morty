import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/character/data/datasources/character_remote_datasource.dart';
import 'package:prueba_tecnica_1/feature/character/data/model/character_model.dart';
import 'package:prueba_tecnica_1/feature/character/data/repositories/character_repository_impl.dart';

class MockRemoteDatasource extends Mock implements CharacterRemoteDatasource {}

void main() {
  late MockRemoteDatasource remote;
  late CharacterRepositoryImpl repository;

  setUp(() {
    remote = MockRemoteDatasource();
    repository = CharacterRepositoryImpl(remote);
  });

  test('should return Character when datasource succeeds', () async {
    // Arrange
    final tCharacterModel = CharacterModel(
      id: 1,
      name: 'Rick',
      status: 'Alive',
      species: 'Human',
      gender: 'Male',
      origin: OriginModel(name: 'Earth', url: 'url'),
      image: 'url',
      episode: ['1'],
    );
    when(
      () => remote.getCharacters(id: 1),
    ).thenAnswer((_) async => tCharacterModel);
    // Act
    final result = await repository.getCharacter(id: 1);

    // Assert
    expect(result.isRight(), true);

    result.fold((_) => fail('Expected Right'), (character) {
      expect(character.id, 1);
      expect(character.name, 'Rick');
    });
    verify(() => remote.getCharacters(id: 1)).called(1);
  });

  test('should return an exception when the statuscode is 500', () async {
    when(
      () => remote.getCharacters(id: 1),
    ).thenThrow(ServerException(statusCode: 500, message: 'error'));

    final result = await repository.getCharacter(id: 1);

    expect(result, isA<Left>());
  });

  test('should return an exception when networkexception', () async {
    when(() => remote.getCharacters(id: 1)).thenThrow(NetworkException());

    final result = await repository.getCharacter(id: 1);

    expect(result, isA<Left>());
    result.fold((l) {
      expect(l.message, 'No internet connection');
      expect(l, isA<NetworkFailure>());
    }, (r) {});
  });

  test('should return an exception when parsingException', () async {
    when(() => remote.getCharacters(id: 1)).thenThrow(ParsingException());

    final result = await repository.getCharacter(id: 1);

    expect(result, isA<Left>());
    result.fold((l) {
      expect(l.message, 'Parsing error');
      expect(l, isA<ParsingFailure>());
    }, (r) {});
  });
}
