import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/user/domain/entities/user_profile.dart';
import 'package:prueba_tecnica_1/feature/user/domain/repositories/user_repository.dart';
import 'package:prueba_tecnica_1/feature/user/domain/usecase/user_use_case.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository repository;
  late UserUseCase useCase;

  const profile = UserProfile(name: 'Rick', age: 70, country: 'Earth');

  setUp(() {
    repository = MockUserRepository();
    useCase = UserUseCase(repository);
  });

  test('getProfile reads through to the repository', () async {
    when(
      () => repository.getProfile(),
    ).thenAnswer((_) async => const Right(profile));

    final result = await useCase.getProfile();

    expect(result, isA<Right>());
    result.fold((_) => fail('Expected Right'), (p) => expect(p, profile));
    verify(() => repository.getProfile()).called(1);
  });

  test('getProfile returns Failure when repository fails', () async {
    const failure = AuthFailure('Debes iniciar sesión');
    when(
      () => repository.getProfile(),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase.getProfile();

    expect(result, const Left(failure));
  });

  test('saveProfile calls repository with the profile', () async {
    when(
      () => repository.saveProfile(profile),
    ).thenAnswer((_) async => const Right(unit));

    final result = await useCase.saveProfile(profile);

    expect(result, const Right(unit));
    verify(() => repository.saveProfile(profile)).called(1);
  });
}
