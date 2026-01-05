import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/home/domain/repository/characters_repository.dart';
import 'package:prueba_tecnica_1/feature/home/domain/usecase/characters_use_case.dart';

class MockCharactersRepository extends Mock implements CharactersRepository {}

void main() {
  late MockCharactersRepository repository;
  late CharactersUseCase useCase;

  setUp(() {
    repository = MockCharactersRepository();
    useCase = CharactersUseCase(repository);
  });

  group('CharactersUseCase', () {
    final tCharacters = [
      Character(
        id: 1,
        name: 'Rick',
        gender: 'Male',
        status: 'Alive',
        species: 'Human',
        image: 'url',
        origin: Origin(name: 'Earth', url: 'url'),
        episodes: ['1'],
      ),
      Character(
        id: 2,
        name: 'morty',
        gender: 'Male',
        status: 'Alive',
        species: 'Human',
        image: 'url',
        origin: Origin(name: 'Earth', url: 'url'),
        episodes: ['2'],
      ),
    ];

    test('should return characters from repository', () async {
      // arrange
      when(
        () => repository.getCharacters(
          page: any(named: 'page'),
          name: any(named: 'name'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => Right(tCharacters));

      // act
      final result = await useCase();

      // assert
      expect(result, Right(tCharacters));
      verify(
        () => repository.getCharacters(
          page: any(named: 'page'),
          name: any(named: 'name'),
          status: any(named: 'status'),
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('should call repository with page 2', () async {
      // arrange
      when(
        () => repository.getCharacters(page: 2, name: null, status: null),
      ).thenAnswer((_) async => Right(tCharacters));

      // act
      await useCase(page: 2);

      // assert
      verify(
        () => repository.getCharacters(page: 2, name: null, status: null),
      ).called(1);
    });

    test('should call repository with name and status parameters', () async {
      // arrange
      when(
        () => repository.getCharacters(page: 1, name: 'rick', status: 'alive'),
      ).thenAnswer((_) async => Right(tCharacters));

      // act
      await useCase(page: 1, name: 'rick', status: 'alive');

      // assert
      verify(
        () => repository.getCharacters(page: 1, name: 'rick', status: 'alive'),
      ).called(1);
    });

    test('should return Failure when repository fails', () async {
      //Arrange
      final failure = ServerFailure(message: 'Server error', statusCode: 404);

      when(
        () => repository.getCharacters(),
      ).thenAnswer((_) async => Left(failure));

      //Act
      final result = await useCase();

      //Assert
      expect(result, Left(failure));
      verify(() => repository.getCharacters()).called(1);
    });
  });
}
