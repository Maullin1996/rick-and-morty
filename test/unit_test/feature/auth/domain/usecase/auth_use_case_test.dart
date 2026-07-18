import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/auth/domain/repositories/auth_repository.dart';
import 'package:prueba_tecnica_1/feature/auth/domain/usecase/auth_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late AuthUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = AuthUseCase(repository);
  });

  test('isLoggedIn reads through to the repository', () {
    when(() => repository.isLoggedIn).thenReturn(true);

    expect(useCase.isLoggedIn, true);
    verify(() => repository.isLoggedIn).called(1);
  });

  test('currentUserEmail reads through to the repository', () {
    when(() => repository.currentUserEmail).thenReturn('a@a.com');

    expect(useCase.currentUserEmail, 'a@a.com');
    verify(() => repository.currentUserEmail).called(1);
  });

  test('authStateChanges reads through to the repository', () {
    when(() => repository.authStateChanges).thenAnswer(
      (_) => Stream.value(true),
    );

    expect(useCase.authStateChanges, emits(true));
  });

  test('signIn calls repository with email and password', () async {
    when(
      () => repository.signIn(email: 'a@a.com', password: '123456'),
    ).thenAnswer((_) async => const Right(unit));

    final result = await useCase.signIn(email: 'a@a.com', password: '123456');

    expect(result, const Right(unit));
    verify(
      () => repository.signIn(email: 'a@a.com', password: '123456'),
    ).called(1);
  });

  test('signIn returns Failure when repository fails', () async {
    const failure = AuthFailure('Correo o contraseña incorrectos');
    when(
      () => repository.signIn(email: 'a@a.com', password: '123456'),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase.signIn(email: 'a@a.com', password: '123456');

    expect(result, const Left(failure));
  });

  test('register calls repository with email and password', () async {
    when(
      () => repository.register(email: 'a@a.com', password: '123456'),
    ).thenAnswer((_) async => const Right(unit));

    final result = await useCase.register(
      email: 'a@a.com',
      password: '123456',
    );

    expect(result, const Right(unit));
    verify(
      () => repository.register(email: 'a@a.com', password: '123456'),
    ).called(1);
  });

  test('signInWithGoogle calls repository', () async {
    when(
      () => repository.signInWithGoogle(),
    ).thenAnswer((_) async => const Right(unit));

    final result = await useCase.signInWithGoogle();

    expect(result, const Right(unit));
    verify(() => repository.signInWithGoogle()).called(1);
  });

  test('signOut calls repository', () async {
    when(() => repository.signOut()).thenAnswer((_) async {});

    await useCase.signOut();

    verify(() => repository.signOut()).called(1);
  });
}
