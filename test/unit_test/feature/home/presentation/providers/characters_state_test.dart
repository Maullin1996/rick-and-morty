import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/home/domain/usecase/characters_use_case.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/providers/characters_providers.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/providers/characters_state.dart';

class MockCharactersUseCase extends Mock implements CharactersUseCase {}

void main() {
  late ProviderContainer container;
  late MockCharactersUseCase useCase;

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
  ];

  final tCharacters2 = [
    Character(
      id: 1,
      name: 'Morty',
      gender: 'Male',
      status: 'Alive',
      species: 'Human',
      image: 'url',
      origin: Origin(name: 'Earth', url: 'url'),
      episodes: ['2'],
    ),
  ];

  setUp(() {
    useCase = MockCharactersUseCase();
    container = ProviderContainer(
      overrides: [getCharactersUseCaseProvider.overrideWithValue(useCase)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('should start with initial state', () {
    final state = container.read(charactersProvider);

    expect(state, const CharactersState.initial());
  });

  test('Should load character', () async {
    // Arrange
    when(
      () => useCase(page: 1, status: null),
    ).thenAnswer((_) async => Right(tCharacters));

    //Act

    await container.read(charactersProvider.notifier).loadInitial();

    final state = container.read(charactersProvider);

    state.when(
      initial: () => fail('Should not be initial'),
      loading: (_) => fail('Should not be loading'),
      error: (_, __) => fail('Should not be error'),
      loaded: (characters, hasMore) {
        expect(characters.length, 1);
        expect(characters.first.name, 'Rick');
        expect(hasMore, true);
      },
    );
  });

  test('Should retorn error when NetworkFailure', () async {
    // Arrenge
    when(
      () => useCase(page: 1, status: null),
    ).thenAnswer((_) async => Left(NetworkFailure('No internet')));

    await container.read(charactersProvider.notifier).loadInitial();

    container
        .read(charactersProvider)
        .when(
          initial: () => fail('Should not be initial'),
          loading: (_) => fail('Should not be loading'),
          loaded: (_, __) => ('Should not be loaded'),
          error: (message, characters) {
            expect(message, 'No internet');
          },
        );
  });

  test('Should load more characters when loadMore', () async {
    // Arrange
    when(
      () => useCase(page: 1, status: null),
    ).thenAnswer((_) async => Right(tCharacters));
    await container.read(charactersProvider.notifier).loadInitial();

    when(
      () => useCase(page: 2, status: null),
    ).thenAnswer((_) async => Right(tCharacters2));

    await container.read(charactersProvider.notifier).loadMore();

    final state = container.read(charactersProvider);

    state.when(
      initial: () => fail('Should not be initial'),
      loading: (_) => fail('Should not be loading'),
      loaded: (characters, hasMore) {
        expect(characters.length, 2);
        expect(characters[1].name, 'Morty');
        expect(hasMore, true);
      },
      error: (_, __) => fail('Should not be error'),
    );
  });

  test("LoadMore doesn't do anything if hasMore = false", () async {
    // Arrange
    when(
      () => useCase(page: 1, status: null),
    ).thenAnswer((_) async => Right([]));

    await container.read(charactersProvider.notifier).loadInitial();

    when(
      () => useCase(page: 2, status: null),
    ).thenAnswer((_) async => Right(tCharacters));

    await container.read(charactersProvider.notifier).loadMore();

    final state = container.read(charactersProvider);

    state.when(
      initial: () => fail('Should not be initial'),
      loading: (_) => fail('Should not be loading'),
      loaded: (characters, hasMore) {
        expect(characters.length, 0);
        expect(hasMore, false);
      },
      error: (_, __) => fail('Should not be error'),
    );
  });
  test('loading should maintain previous characters', () async {
    // Arrange
    when(
      () => useCase(page: 1, status: null),
    ).thenAnswer((_) async => Right(tCharacters));

    await container.read(charactersProvider.notifier).loadInitial();

    when(
      () => useCase(page: 2, status: null),
    ).thenAnswer((_) async => Right(tCharacters2));

    CharactersState? loadingState;

    final listener = container.listen<CharactersState>(charactersProvider, (
      previous,
      next,
    ) {
      next.maybeWhen(loading: (_) => loadingState = next, orElse: () {});
    }, fireImmediately: false);

    // Act
    await container.read(charactersProvider.notifier).loadMore();

    // Assert
    expect(loadingState, isNotNull);

    loadingState!.when(
      initial: () => fail('Should not be initial'),
      loading: (characters) {
        expect(characters.length, 1);
        expect(characters.first.name, 'Rick');
      },
      loaded: (_, __) => fail('Should not be loaded'),
      error: (_, __) => fail('Should not be error'),
    );

    listener.close();
  });
}
