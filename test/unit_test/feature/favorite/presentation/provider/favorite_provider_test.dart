import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/core/services/shared_preferences_services_provider.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/favorite/presentation/providers/favorite_provider.dart';

import 'fake_shared_preferences_service.dart';

void main() {
  late ProviderContainer container;
  late FakeSharedPreferencesService fakeService;

  setUp(() {
    fakeService = FakeSharedPreferencesService();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesServiceProvider.overrideWithValue(fakeService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state should be empty when no favorites are stored', () {
    final favorites = container.read(favoriteProvider);

    expect(favorites, isEmpty);
  });

  test('addCharacter should add character to favorites', () {
    final notifier = container.read(favoriteProvider.notifier);

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

    notifier.addCharacter(character);
    final favorites = container.read(favoriteProvider);

    expect(favorites.length, 1);
    expect(favorites.first.id, 1);
  });
  test('toggleCharacter should remove character if already exists', () {
    final notifier = container.read(favoriteProvider.notifier);

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

    notifier.addCharacter(character);
    notifier.toggleCharacter(character);

    final favorites = container.read(favoriteProvider);

    expect(favorites, isEmpty);
  });

  test('toggleCharacter should add character if it is not exists', () {
    final notifier = container.read(favoriteProvider.notifier);

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

    notifier.toggleCharacter(character);

    final favorites = container.read(favoriteProvider);

    expect(favorites, isNotEmpty);
    expect(favorites.first.origin.name, 'Earth');
    expect(favorites.first.status, 'Alive');
  });

  test('isFavorite should return true or false is the element is added', () {
    final notifier = container.read(favoriteProvider.notifier);

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

    notifier.toggleCharacter(character);

    final isFavorite = notifier.isFavorite(1);
    final isNotFavorite = notifier.isFavorite(2);

    expect(isFavorite, equals(true));
    expect(isNotFavorite, equals(false));
  });

  test('clearAll should clear all elements in the list', () {
    final notifier = container.read(favoriteProvider.notifier);

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

    notifier.toggleCharacter(character);

    final favorites = container.read(favoriteProvider);

    expect(favorites.length, 1);
    expect(favorites.first.id, 1);

    notifier.clearAll();

    final newFavorites = container.read(favoriteProvider);

    expect(newFavorites.length, 0);
  });

  test('favorites should persist after recreating ProviderContainer', () {
    final notifier = container.read(favoriteProvider.notifier);

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

    notifier.addCharacter(character);

    final favoritesBeforeDispose = container.read(favoriteProvider);
    expect(favoritesBeforeDispose.length, 1);

    container.dispose();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesServiceProvider.overrideWithValue(fakeService),
      ],
    );

    final favoritesAfterRebuild = container.read(favoriteProvider);

    expect(favoritesAfterRebuild.length, 1);
    expect(favoritesAfterRebuild.first.id, 1);
  });
}
