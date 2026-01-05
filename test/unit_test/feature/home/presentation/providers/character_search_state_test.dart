import 'package:dartz/dartz.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/home/domain/usecase/characters_use_case.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/providers/character_search_state.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/providers/characters_providers.dart';

class MockCharactersUseCase extends Mock implements CharactersUseCase {}

void main() {
  late ProviderContainer container;
  late MockCharactersUseCase useCase;

  setUp(() {
    useCase = MockCharactersUseCase();
    container = ProviderContainer(
      overrides: [getCharactersUseCaseProvider.overrideWithValue(useCase)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  final characters = [
    Character(
      id: 1,
      name: 'Rick Sanchez',
      gender: 'Male',
      status: 'Alive',
      species: 'Human',
      image: 'url',
      origin: Origin(name: 'Earth', url: ''),
      episodes: ['1'],
    ),
  ];

  final listCharacters = [
    Character(
      id: 1,
      name: 'Rick',
      gender: 'Male',
      status: 'Alive',
      species: 'Human',
      image: 'url',
      origin: Origin(name: 'Earth', url: ''),
      episodes: ['1'],
    ),
    Character(
      id: 2,
      name: 'Rick Prime',
      gender: 'Male',
      status: 'Alive',
      species: 'Human',
      image: 'url',
      origin: Origin(name: 'Earth', url: ''),
      episodes: ['1', '2'],
    ),
    Character(
      id: 1,
      name: 'Evil Rick',
      gender: 'Male',
      status: 'Dead',
      species: 'Human',
      image: 'url',
      origin: Origin(name: 'Earth', url: ''),
      episodes: ['58'],
    ),
  ];
  test('starts with initial state', () {
    final state = container.read(characterSearchProvider);

    expect(state, CharacterSearchState.initial());
  });

  test('search with empty query resets to initial', () {
    final notifier = container.read(characterSearchProvider.notifier);

    notifier.search('');

    final state = container.read(characterSearchProvider);

    expect(state, const CharacterSearchState.initial());
    verifyNever(
      () => useCase.call(
        page: any(named: 'page'),
        name: any(named: 'name'),
      ),
    );
  });

  test('search emits loading then loaded on success', () async {
    when(
      () => useCase.call(page: 1, name: 'rick'),
    ).thenAnswer((_) async => Right(characters));

    final notifier = container.read(characterSearchProvider.notifier);

    notifier.search('rick');

    // ⏱️ Esperamos el debounce
    await Future.delayed(const Duration(milliseconds: 400));

    final state = container.read(characterSearchProvider);

    state.when(
      initial: () => fail('Should not be initial'),
      loading: () => fail('Should not be loading'),
      loaded: (results) {
        expect(results.length, 1);
        expect(results.first.name, 'Rick Sanchez');
      },
      error: (_) => fail('Should not be error'),
    );
  });

  test('search emits error when use case fails', () async {
    when(() => useCase.call(page: 1, name: 'morty')).thenAnswer(
      (_) async =>
          Left(ServerFailure(message: 'Server error', statusCode: 500)),
    );

    final notifier = container.read(characterSearchProvider.notifier);

    notifier.search('morty');

    await Future.delayed(const Duration(milliseconds: 400));

    final state = container.read(characterSearchProvider);

    state.when(
      initial: () => fail('Should not be initial'),
      loading: () => fail('Should not be loading'),
      loaded: (_) => fail('Should no has characters'),
      error: (message) {
        expect(message, 'Server error');
      },
    );
  });

  test('Usecase is call only one time', () async {
    when(
      () => useCase.call(page: 1, name: 'rick'),
    ).thenAnswer((_) async => Right(characters));
    final notifier = container.read(characterSearchProvider.notifier);

    notifier.search('r');
    notifier.search('ri');
    notifier.search('rick');

    await Future.delayed(const Duration(milliseconds: 400));

    verify(
      () => useCase.call(
        page: any(named: 'page'),
        name: 'rick',
      ),
    ).called(1);
  });

  test('Usecase is called only once with debounce', () {
    when(
      () => useCase.call(page: 1, name: 'rick'),
    ).thenAnswer((_) async => Right(characters));

    fakeAsync((async) {
      final notifier = container.read(characterSearchProvider.notifier);

      notifier.search('r');
      notifier.search('ri');
      notifier.search('rick');

      // ⏱️ Avanzamos el tiempo artificialmente
      async.elapse(const Duration(milliseconds: 350));

      verify(() => useCase.call(page: 1, name: 'rick')).called(1);
    });
  });

  test('Should return Initial when clear() is call', () {
    final notifier = container.read(characterSearchProvider.notifier);
    notifier.clear();

    final state = container.read(characterSearchProvider);

    expect(state, const CharacterSearchState.initial());
    verifyNever(
      () => useCase.call(
        page: any(named: 'page'),
        name: any(named: 'name'),
      ),
    );
  });

  test(
    'Should order the characters and return the correct character',
    () async {
      when(
        () => useCase.call(page: 1, name: 'rick'),
      ).thenAnswer((_) async => Right(listCharacters));

      final notifier = container.read(characterSearchProvider.notifier);

      notifier.search('rick');

      await Future.delayed(const Duration(milliseconds: 400));

      final state = container.read(characterSearchProvider);

      state.when(
        initial: () => fail('Should not be initial'),
        loading: () => fail('Should not be loading'),
        loaded: (results) {
          expect(results.length, 3);
          expect(results.first.name, 'Rick');
        },
        error: (_) => fail('Should not be error'),
      );
    },
  );
}
