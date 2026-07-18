import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/favorite/domain/repositories/favorite_repository.dart';
import 'package:prueba_tecnica_1/feature/favorite/domain/usecase/favorite_use_case.dart';

class MockFavoriteRepository extends Mock implements FavoriteRepository {}

void main() {
  late MockFavoriteRepository repository;
  late FavoriteUseCase useCase;

  final character = Character(
    id: 1,
    name: 'Rick',
    gender: 'Male',
    status: 'Alive',
    species: 'Human',
    image: 'url',
    origin: Origin(name: 'Earth', url: 'url'),
    episodes: ['1'],
  );

  setUp(() {
    repository = MockFavoriteRepository();
    useCase = FavoriteUseCase(repository);
  });

  test('getFavorites reads through to the repository', () async {
    when(
      () => repository.getFavorites(),
    ).thenAnswer((_) async => Right([character]));

    final result = await useCase.getFavorites();

    expect(result, isA<Right>());
    result.fold(
      (_) => fail('Expected Right'),
      (favorites) => expect(favorites, [character]),
    );
    verify(() => repository.getFavorites()).called(1);
  });

  test('getFavorites returns Failure when repository fails', () async {
    const failure = AuthFailure('Debes iniciar sesión');
    when(
      () => repository.getFavorites(),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase.getFavorites();

    expect(result, const Left(failure));
  });

  test('addFavorite calls repository with the character', () async {
    when(
      () => repository.addFavorite(character),
    ).thenAnswer((_) async => const Right(unit));

    final result = await useCase.addFavorite(character);

    expect(result, const Right(unit));
    verify(() => repository.addFavorite(character)).called(1);
  });

  test('removeFavorite calls repository with the id', () async {
    when(
      () => repository.removeFavorite(1),
    ).thenAnswer((_) async => const Right(unit));

    final result = await useCase.removeFavorite(1);

    expect(result, const Right(unit));
    verify(() => repository.removeFavorite(1)).called(1);
  });
}
