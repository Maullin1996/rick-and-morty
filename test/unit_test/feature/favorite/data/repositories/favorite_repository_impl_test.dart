import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/auth/domain/usecase/auth_use_case.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/favorite/data/datasources/favorite_remote_datasource.dart';
import 'package:prueba_tecnica_1/feature/favorite/data/repositories/favorite_repository_impl.dart';

class MockFavoriteRemoteDatasource extends Mock
    implements FavoriteRemoteDatasource {}

class MockAuthUseCase extends Mock implements AuthUseCase {}

void main() {
  late MockFavoriteRemoteDatasource remote;
  late MockAuthUseCase authUseCase;
  late FavoriteRepositoryImpl repository;

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
    remote = MockFavoriteRemoteDatasource();
    authUseCase = MockAuthUseCase();
    repository = FavoriteRepositoryImpl(remote, authUseCase);
  });

  group('getFavorites', () {
    test('returns Right with the favorites when the datasource succeeds', () async {
      when(() => authUseCase.currentUserId).thenReturn('uid1');
      when(
        () => remote.getFavorites('uid1'),
      ).thenAnswer((_) async => [character]);

      final result = await repository.getFavorites();

      expect(result, isA<Right>());
      result.fold(
        (_) => fail('Expected Right'),
        (favorites) => expect(favorites, [character]),
      );
    });

    test('returns AuthFailure when there is no logged in user', () async {
      when(() => authUseCase.currentUserId).thenReturn(null);

      final result = await repository.getFavorites();

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
      verifyNever(() => remote.getFavorites(any()));
    });

    test('returns ServerFailure when datasource throws ServerException', () async {
      when(() => authUseCase.currentUserId).thenReturn('uid1');
      when(
        () => remote.getFavorites('uid1'),
      ).thenThrow(const ServerException(message: 'Firestore error', statusCode: 0));

      final result = await repository.getFavorites();

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns UnknownFailure when datasource throws an unexpected error', () async {
      when(() => authUseCase.currentUserId).thenReturn('uid1');
      when(() => remote.getFavorites('uid1')).thenThrow(Exception('boom'));

      final result = await repository.getFavorites();

      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('addFavorite', () {
    test('returns Right(unit) when the datasource succeeds', () async {
      when(() => authUseCase.currentUserId).thenReturn('uid1');
      when(
        () => remote.addFavorite('uid1', character),
      ).thenAnswer((_) async {});

      final result = await repository.addFavorite(character);

      expect(result, const Right(unit));
      verify(() => remote.addFavorite('uid1', character)).called(1);
    });
  });

  group('removeFavorite', () {
    test('returns Right(unit) when the datasource succeeds', () async {
      when(() => authUseCase.currentUserId).thenReturn('uid1');
      when(
        () => remote.removeFavorite('uid1', character.id),
      ).thenAnswer((_) async {});

      final result = await repository.removeFavorite(character.id);

      expect(result, const Right(unit));
      verify(() => remote.removeFavorite('uid1', character.id)).called(1);
    });
  });
}
