import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/providers/auth_provider.dart';
import 'package:prueba_tecnica_1/feature/user/domain/entities/user_profile.dart';
import 'package:prueba_tecnica_1/feature/user/domain/usecase/user_use_case.dart';
import 'package:prueba_tecnica_1/feature/user/presentation/providers/user_provider.dart';
import 'package:prueba_tecnica_1/feature/user/presentation/providers/user_providers.dart';

class MockUserUseCase extends Mock implements UserUseCase {}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(this._loggedIn);
  final bool _loggedIn;

  @override
  bool build() => _loggedIn;
}

class FakeUserProfile extends Fake implements UserProfile {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUserProfile());
  });

  late MockUserUseCase useCase;
  late ProviderContainer container;

  const profile = UserProfile(name: 'Rick', age: 70, country: 'Earth');

  ProviderContainer makeContainer({required bool loggedIn}) {
    useCase = MockUserUseCase();
    when(() => useCase.getProfile()).thenAnswer((_) async => const Right(null));
    when(
      () => useCase.saveProfile(any()),
    ).thenAnswer((_) async => const Right(unit));

    return ProviderContainer(
      overrides: [
        userUseCaseProvider.overrideWithValue(useCase),
        isLoggedInProvider.overrideWith(() => FakeAuthNotifier(loggedIn)),
      ],
    );
  }

  tearDown(() {
    container.dispose();
  });

  test('build returns null without querying when logged out', () async {
    container = makeContainer(loggedIn: false);

    final result = container.read(userProfileProvider);

    expect(result, isNull);
    verifyNever(() => useCase.getProfile());
  });

  test('build loads the profile from the use case when logged in', () async {
    useCase = MockUserUseCase();
    when(
      () => useCase.getProfile(),
    ).thenAnswer((_) async => const Right(profile));

    container = ProviderContainer(
      overrides: [
        userUseCaseProvider.overrideWithValue(useCase),
        isLoggedInProvider.overrideWith(() => FakeAuthNotifier(true)),
      ],
    );

    container.read(userProfileProvider);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(userProfileProvider), profile);
  });

  test('saveProfile updates state and returns true on success', () async {
    container = makeContainer(loggedIn: true);
    await Future<void>.delayed(Duration.zero);

    final notifier = container.read(userProfileProvider.notifier);
    final success = await notifier.saveProfile(profile);

    expect(success, isTrue);
    expect(container.read(userProfileProvider), profile);
    verify(() => useCase.saveProfile(profile)).called(1);
  });

  test('saveProfile leaves state untouched and returns false on failure', () async {
    container = makeContainer(loggedIn: true);
    when(
      () => useCase.saveProfile(any()),
    ).thenAnswer((_) async => const Left(AuthFailure('Debes iniciar sesión')));
    await Future<void>.delayed(Duration.zero);

    final notifier = container.read(userProfileProvider.notifier);
    final success = await notifier.saveProfile(profile);

    expect(success, isFalse);
    expect(container.read(userProfileProvider), isNull);
  });
}
