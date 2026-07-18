import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/providers/auth_provider.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/favorite/domain/usecase/favorite_use_case.dart';
import 'package:prueba_tecnica_1/feature/favorite/presentation/providers/favorite_provider.dart';
import 'package:prueba_tecnica_1/feature/favorite/presentation/providers/favorite_providers.dart';

class MockFavoriteUseCase extends Mock implements FavoriteUseCase {}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(this._loggedIn);
  final bool _loggedIn;

  @override
  bool build() => _loggedIn;
}

class FakeCharacter extends Fake implements Character {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCharacter());
  });

  late MockFavoriteUseCase useCase;
  late ProviderContainer container;

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

  ProviderContainer makeContainer({required bool loggedIn}) {
    useCase = MockFavoriteUseCase();
    when(() => useCase.getFavorites()).thenAnswer((_) async => const Right([]));
    when(
      () => useCase.addFavorite(any()),
    ).thenAnswer((_) async => const Right(unit));
    when(
      () => useCase.removeFavorite(any()),
    ).thenAnswer((_) async => const Right(unit));

    return ProviderContainer(
      overrides: [
        favoriteUseCaseProvider.overrideWithValue(useCase),
        isLoggedInProvider.overrideWith(() => FakeAuthNotifier(loggedIn)),
      ],
    );
  }

  tearDown(() {
    container.dispose();
  });

  test('build returns empty list without querying when logged out', () async {
    container = makeContainer(loggedIn: false);

    final favorites = container.read(favoriteProvider);

    expect(favorites, isEmpty);
    verifyNever(() => useCase.getFavorites());
  });

  test('build loads favorites from the use case when logged in', () async {
    useCase = MockFavoriteUseCase();
    when(
      () => useCase.getFavorites(),
    ).thenAnswer((_) async => Right([character]));

    container = ProviderContainer(
      overrides: [
        favoriteUseCaseProvider.overrideWithValue(useCase),
        isLoggedInProvider.overrideWith(() => FakeAuthNotifier(true)),
      ],
    );

    container.read(favoriteProvider);
    await Future<void>.delayed(Duration.zero);

    final favorites = container.read(favoriteProvider);

    expect(favorites.length, 1);
    expect(favorites.first.id, 1);
  });

  test('addCharacter should add character to favorites', () async {
    container = makeContainer(loggedIn: true);
    await Future<void>.delayed(Duration.zero);

    final notifier = container.read(favoriteProvider.notifier);
    notifier.addCharacter(character);

    final favorites = container.read(favoriteProvider);

    expect(favorites.length, 1);
    expect(favorites.first.id, 1);
    verify(() => useCase.addFavorite(character)).called(1);
  });

  test('toggleCharacter should remove character if already exists', () async {
    container = makeContainer(loggedIn: true);
    await Future<void>.delayed(Duration.zero);

    final notifier = container.read(favoriteProvider.notifier);

    notifier.addCharacter(character);
    notifier.toggleCharacter(character);

    final favorites = container.read(favoriteProvider);

    expect(favorites, isEmpty);
    verify(() => useCase.removeFavorite(character.id)).called(1);
  });

  test('toggleCharacter should add character if it does not exist', () async {
    container = makeContainer(loggedIn: true);
    await Future<void>.delayed(Duration.zero);

    final notifier = container.read(favoriteProvider.notifier);
    notifier.toggleCharacter(character);

    final favorites = container.read(favoriteProvider);

    expect(favorites, isNotEmpty);
    expect(favorites.first.origin.name, 'Earth');
    expect(favorites.first.status, 'Alive');
  });

  test('isFavorite should return true or false if the element is added', () async {
    container = makeContainer(loggedIn: true);
    await Future<void>.delayed(Duration.zero);

    final notifier = container.read(favoriteProvider.notifier);
    notifier.toggleCharacter(character);

    expect(notifier.isFavorite(1), isTrue);
    expect(notifier.isFavorite(2), isFalse);
  });

  test('clearAll should clear all elements in the list', () async {
    container = makeContainer(loggedIn: true);
    await Future<void>.delayed(Duration.zero);

    final notifier = container.read(favoriteProvider.notifier);
    notifier.addCharacter(character);

    expect(container.read(favoriteProvider).length, 1);

    notifier.clearAll();

    expect(container.read(favoriteProvider), isEmpty);
  });
}
