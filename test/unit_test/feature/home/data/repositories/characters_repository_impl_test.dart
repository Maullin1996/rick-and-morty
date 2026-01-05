import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/character/data/model/character_model.dart';
import 'package:prueba_tecnica_1/feature/home/data/datasources/characters_remote_datasource.dart';
import 'package:prueba_tecnica_1/feature/home/data/repositories/characters_repository_impl.dart';

class MockRemoteDatasource extends Mock implements CharactersRemoteDatasource {}

void main() {
  late MockRemoteDatasource remote;
  late CharactersRepositoryImpl repository;

  setUp(() {
    remote = MockRemoteDatasource();
    repository = CharactersRepositoryImpl(remote);
  });

  final tCharacters = [
    CharacterModel(
      id: 1,
      name: 'Rick',
      gender: 'Male',
      status: 'Alive',
      species: 'Human',
      image: 'url',
      origin: OriginModel(name: 'Earth', url: 'url'),
      episode: ["1"],
    ),
    CharacterModel(
      id: 2,
      name: 'morty',
      gender: 'Male',
      status: 'Alive',
      species: 'Human',
      image: 'url',
      origin: OriginModel(name: 'Earth', url: 'url'),
      episode: ['2'],
    ),
  ];

  test('should return Character when datasource succeeds', () async {
    // Arrange
    when(() => remote.getCharacters()).thenAnswer((_) async => tCharacters);
    // Act
    final result = await repository.getCharacters();

    //Assert
    expect(result.isRight(), true);
    result.fold((_) => fail('Expected Right'), (character) {
      expect(character[1].id, 2);
      expect(character[0].name, 'Rick');
    });
    verify(() => remote.getCharacters()).called(1);
  });

  test('should return an exception when the statuscode is 500', () async {
    when(
      () => remote.getCharacters(),
    ).thenThrow(ServerException(statusCode: 500, message: 'error'));

    final result = await repository.getCharacters();

    expect(result, isA<Left>());
  });

  test('should return an exception when networkexception', () async {
    when(() => remote.getCharacters()).thenThrow(NetworkException());
    final result = await repository.getCharacters();

    expect(result, isA<Left>());
    result.fold((l) {
      expect(l.message, 'No internet connection');
      expect(l, isA<NetworkFailure>());
    }, (r) {});
  });

  test('should return an exception when parsingException', () async {
    when(() => remote.getCharacters()).thenThrow(ParsingException());

    final result = await repository.getCharacters();

    expect(result, isA<Left>());
    result.fold((l) {
      expect(l.message, 'Parsing error');
      expect(l, isA<ParsingFailure>());
    }, (r) {});
  });
}
