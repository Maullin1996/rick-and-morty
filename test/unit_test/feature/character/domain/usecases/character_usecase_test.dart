import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/character/domain/repositories/character_repository.dart';
import 'package:prueba_tecnica_1/feature/character/domain/usecase/character_use_case.dart';

class MockCharacterRepository extends Mock implements CharacterRepository {}

void main() {
  late MockCharacterRepository repository;
  late CharacterUseCase useCase;

  setUp(() {
    repository = MockCharacterRepository();
    useCase = CharacterUseCase(repository);
  });

  group('CharacterUseCase', () {
    const tId = 1;
    final tCharacter = Character(
      id: 1,
      name: 'Rick',
      gender: 'Male',
      status: 'Alive',
      species: 'Human',
      image: 'url',
      origin: Origin(name: 'Earth', url: 'url'),
      episodes: ['1'],
    );

    test('should get character from repository', () async {
      // Arrange
      when(
        () => repository.getCharacter(id: tId),
      ).thenAnswer((_) async => Right(tCharacter));

      // Act
      final result = await useCase(id: tId);

      // Assert
      expect(result, Right(tCharacter));
      verify(() => repository.getCharacter(id: tId)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('should return Failure when repository fails', () async {
      // Arrange
      final failure = ServerFailure(message: 'Server error', statusCode: 404);

      when(
        () => repository.getCharacter(id: tId),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase(id: tId);

      // Asssert
      expect(result, Left(failure));
      verify(() => repository.getCharacter(id: tId)).called(1);
    });
  });
}
