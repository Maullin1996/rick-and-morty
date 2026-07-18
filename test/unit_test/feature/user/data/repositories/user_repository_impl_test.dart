import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/auth/domain/usecase/auth_use_case.dart';
import 'package:prueba_tecnica_1/feature/user/data/datasources/user_remote_datasource.dart';
import 'package:prueba_tecnica_1/feature/user/data/repositories/user_repository_impl.dart';
import 'package:prueba_tecnica_1/feature/user/domain/entities/user_profile.dart';

class MockUserRemoteDatasource extends Mock implements UserRemoteDatasource {}

class MockAuthUseCase extends Mock implements AuthUseCase {}

class FakeUserProfile extends Fake implements UserProfile {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUserProfile());
  });

  late MockUserRemoteDatasource remote;
  late MockAuthUseCase authUseCase;
  late UserRepositoryImpl repository;

  const profile = UserProfile(name: 'Rick', age: 70, country: 'Earth');

  setUp(() {
    remote = MockUserRemoteDatasource();
    authUseCase = MockAuthUseCase();
    repository = UserRepositoryImpl(remote, authUseCase);
  });

  group('getProfile', () {
    test('returns Right with the profile when the datasource succeeds', () async {
      when(() => authUseCase.currentUserId).thenReturn('uid1');
      when(() => remote.getProfile('uid1')).thenAnswer((_) async => profile);

      final result = await repository.getProfile();

      expect(result, isA<Right>());
      result.fold((_) => fail('Expected Right'), (p) => expect(p, profile));
    });

    test('returns Right(null) when the profile does not exist yet', () async {
      when(() => authUseCase.currentUserId).thenReturn('uid1');
      when(() => remote.getProfile('uid1')).thenAnswer((_) async => null);

      final result = await repository.getProfile();

      result.fold((_) => fail('Expected Right'), (p) => expect(p, isNull));
    });

    test('returns AuthFailure when there is no logged in user', () async {
      when(() => authUseCase.currentUserId).thenReturn(null);

      final result = await repository.getProfile();

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
      verifyNever(() => remote.getProfile(any()));
    });

    test('returns ServerFailure when datasource throws ServerException', () async {
      when(() => authUseCase.currentUserId).thenReturn('uid1');
      when(
        () => remote.getProfile('uid1'),
      ).thenThrow(const ServerException(message: 'Firestore error', statusCode: 0));

      final result = await repository.getProfile();

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns UnknownFailure when datasource throws an unexpected error', () async {
      when(() => authUseCase.currentUserId).thenReturn('uid1');
      when(() => remote.getProfile('uid1')).thenThrow(Exception('boom'));

      final result = await repository.getProfile();

      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('saveProfile', () {
    test('returns Right(unit) when the datasource succeeds', () async {
      when(() => authUseCase.currentUserId).thenReturn('uid1');
      when(() => remote.saveProfile('uid1', profile)).thenAnswer((_) async {});

      final result = await repository.saveProfile(profile);

      expect(result, const Right(unit));
      verify(() => remote.saveProfile('uid1', profile)).called(1);
    });

    test('returns AuthFailure when there is no logged in user', () async {
      when(() => authUseCase.currentUserId).thenReturn(null);

      final result = await repository.saveProfile(profile);

      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
      verifyNever(() => remote.saveProfile(any(), any()));
    });
  });
}
