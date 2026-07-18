import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/auth/data/datasources/auth_remote_datasource.dart';
import 'package:prueba_tecnica_1/feature/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}

void main() {
  late MockAuthRemoteDatasource remote;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = MockAuthRemoteDatasource();
    repository = AuthRepositoryImpl(remote);
  });

  test('isLoggedIn reads through to the datasource', () {
    when(() => remote.isLoggedIn).thenReturn(true);

    expect(repository.isLoggedIn, true);
  });

  test('currentUserEmail reads through to the datasource', () {
    when(() => remote.currentUserEmail).thenReturn('a@a.com');

    expect(repository.currentUserEmail, 'a@a.com');
  });

  test('authStateChanges reads through to the datasource', () {
    when(() => remote.authStateChanges).thenAnswer((_) => Stream.value(true));

    expect(repository.authStateChanges, emits(true));
  });

  group('signIn', () {
    test('returns Right when datasource succeeds', () async {
      when(
        () => remote.signInWithEmailAndPassword(
          email: 'a@a.com',
          password: '123456',
        ),
      ).thenAnswer((_) async {});

      final result = await repository.signIn(
        email: 'a@a.com',
        password: '123456',
      );

      expect(result, const Right(unit));
    });

    test('returns AuthFailure when datasource throws AuthException', () async {
      when(
        () => remote.signInWithEmailAndPassword(
          email: 'a@a.com',
          password: 'wrong',
        ),
      ).thenThrow(const AuthException('Correo o contraseña incorrectos'));

      final result = await repository.signIn(
        email: 'a@a.com',
        password: 'wrong',
      );

      expect(result, isA<Left>());
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Correo o contraseña incorrectos');
      }, (_) => fail('Expected Left'));
    });
  });

  group('register', () {
    test('returns Right when datasource succeeds', () async {
      when(
        () => remote.createUserWithEmailAndPassword(
          email: 'a@a.com',
          password: '123456',
        ),
      ).thenAnswer((_) async {});

      final result = await repository.register(
        email: 'a@a.com',
        password: '123456',
      );

      expect(result, const Right(unit));
    });

    test('returns AuthFailure when datasource throws AuthException', () async {
      when(
        () => remote.createUserWithEmailAndPassword(
          email: 'a@a.com',
          password: '123456',
        ),
      ).thenThrow(const AuthException('Ya existe una cuenta con este correo'));

      final result = await repository.register(
        email: 'a@a.com',
        password: '123456',
      );

      expect(result, isA<Left>());
    });
  });

  group('signInWithGoogle', () {
    test('returns Right when datasource succeeds', () async {
      when(() => remote.signInWithGoogle()).thenAnswer((_) async {});

      final result = await repository.signInWithGoogle();

      expect(result, const Right(unit));
    });

    test('returns AuthFailure when datasource throws AuthException', () async {
      when(
        () => remote.signInWithGoogle(),
      ).thenThrow(const AuthException('No se pudo iniciar sesión con Google'));

      final result = await repository.signInWithGoogle();

      expect(result, isA<Left>());
    });
  });

  test('signOut calls datasource', () async {
    when(() => remote.signOut()).thenAnswer((_) async {});

    await repository.signOut();

    verify(() => remote.signOut()).called(1);
  });
}
