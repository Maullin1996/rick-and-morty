import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/core/services/shared_preferences_services_provider.dart';
import 'package:prueba_tecnica_1/feature/favorite/presentation/providers/favorite_provider.dart';
import 'package:prueba_tecnica_1/feature/home/domain/repository/characters_repository.dart';
import 'package:prueba_tecnica_1/feature/home/domain/usecase/characters_use_case.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/helpers/map_status.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/providers/characters_providers.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/page/home_page.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/providers/character_search_state.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/providers/characters_state.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/widget/character_card.dart';

Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  GoRouter? router,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        routerConfig:
            router ??
            GoRouter(
              routes: [
                GoRoute(path: '/', builder: (_, __) => child),
                GoRoute(
                  path: '/character',
                  builder: (_, __) =>
                      const Scaffold(body: Text('Character Page')),
                ),
                GoRoute(
                  path: '/favorite',
                  builder: (_, __) =>
                      const Scaffold(body: Text('Favorite Page')),
                ),
              ],
            ),
      ),
    ),
  );

  await tester.pump();
}

class FakeCharactersNotifier extends CharactersNotifier {
  final CharactersState _fakeState;

  FakeCharactersNotifier([this._fakeState = const CharactersState.initial()]);

  @override
  CharactersState build() => _fakeState;

  @override
  Future<void> loadInitial({String? status}) async {}

  @override
  Future<void> loadMore() async {}
}

class FakeCharacterSearchNotifier extends CharacterSearchNotifier {
  final CharacterSearchState _state;

  FakeCharacterSearchNotifier([
    this._state = const CharacterSearchState.initial(),
  ]);

  @override
  CharacterSearchState build() => _state;

  @override
  void search(String query) {}

  @override
  void clear() {}
}

class SpyCharactersNotifier extends CharactersNotifier {
  final CharactersState _state;
  int loadMoreCalls = 0;
  int loadInitialCalls = 0;
  String? lastStatus;

  SpyCharactersNotifier(this._state);

  @override
  CharactersState build() => _state;

  @override
  Future<void> loadInitial({String? status}) async {
    loadInitialCalls++;
    lastStatus = status;
  }

  @override
  Future<void> loadMore() async {
    loadMoreCalls++;
  }

  void setState(CharactersState newState) {
    state = newState;
  }
}

class SpyFavoriteNotifier extends FavoriteNotifier {
  int toggleCalls = 0;

  @override
  List<Character> build() {
    return [];
  }

  @override
  void toggleCharacter(Character character) {
    toggleCalls++;
    state = [character, ...state];
  }
}

class FakeCharactersUseCase implements CharactersUseCase {
  @override
  Future<Either<Failure, List<Character>>> call({
    int page = 1,
    String? status,
    String? name,
  }) async {
    return Right(tCharacters.take(5).toList());
  }

  @override
  CharactersRepository get repo => throw UnimplementedError();
}

final tCharacter = [
  Character(
    id: 1,
    name: 'Rick Sanchez',
    gender: 'Male',
    status: 'Alive',
    species: 'Human',
    image: 'https://test.com/rick.png',
    origin: Origin(name: 'Earth', url: ''),
    episodes: ['1'],
  ),
];

final tCharacters = List.generate(
  30,
  (index) => Character(
    id: index + 1,
    name: 'Rick $index',
    gender: 'Male',
    status: 'Alive',
    species: 'Human',
    image: 'https://test.com/rick_$index.png',
    origin: Origin(name: 'Earth', url: ''),
    episodes: ['$index'],
  ),
);

Future<SharedPreferences> makePrefs() async {
  SharedPreferences.setMockInitialValues({});

  return await SharedPreferences.getInstance();
}

void main() {
  testWidgets('HomePage renders correctly', (widgetTester) async {
    await pumpApp(
      widgetTester,
      const HomePage(),
      overrides: [
        charactersProvider.overrideWith(() => FakeCharactersNotifier()),
        characterSearchProvider.overrideWith(
          () => FakeCharacterSearchNotifier(),
        ),
      ],
    );
    expect(find.text('Rick And Morty'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('shows loading indicator on initial state', (widgetTester) async {
    await pumpApp(
      widgetTester,
      const HomePage(),
      overrides: [
        charactersProvider.overrideWith(
          () => FakeCharactersNotifier(const CharactersState.initial()),
        ),
      ],
    );
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('shows characters grid when loaded', (WidgetTester tester) async {
    await mockNetworkImages(() async {
      await pumpApp(
        tester,
        const HomePage(),
        overrides: [
          sharedPreferencesProvider.overrideWithValue(await makePrefs()),
          charactersProvider.overrideWith(
            () => FakeCharactersNotifier(
              CharactersState.loaded(characters: tCharacter, hasMore: true),
            ),
          ),
          characterSearchProvider.overrideWith(
            () => FakeCharacterSearchNotifier(),
          ),
        ],
      );
      // saber cual es el error
      //final error = tester.takeException();
      //print('TEST EXCEPTION: $error');

      await tester.pump();

      expect(find.text('Rick Sanchez'), findsOneWidget);
      expect(find.byType(CharacterCard), findsOneWidget);
    });
  });

  testWidgets('tap on character navigates to character page', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      const HomePage(),
      overrides: [
        sharedPreferencesProvider.overrideWithValue(await makePrefs()),
        charactersProvider.overrideWith(
          () => FakeCharactersNotifier(
            CharactersState.loaded(characters: tCharacter, hasMore: true),
          ),
        ),
        characterSearchProvider.overrideWith(
          () => FakeCharacterSearchNotifier(),
        ),
      ],
    );

    await tester.tap(find.byType(CharacterCard));
    await tester.pumpAndSettle();

    expect(find.text('Character Page'), findsOneWidget);
  });

  testWidgets('Scroll near bottom calls loadMore', (WidgetTester tester) async {
    await mockNetworkImages(() async {
      final prefs = await makePrefs();

      final spy = SpyCharactersNotifier(
        CharactersState.loaded(characters: tCharacters, hasMore: true),
      );

      await pumpApp(
        tester,
        const HomePage(),
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          charactersProvider.overrideWith(() => spy),
          characterSearchProvider.overrideWith(
            () => FakeCharacterSearchNotifier(),
          ),
        ],
      );

      expect(find.byType(GridView), findsOneWidget);

      final gridScrollable = tester.state<ScrollableState>(
        find.descendant(
          of: find.byType(GridView),
          matching: find.byType(Scrollable),
        ),
      );

      gridScrollable.position.jumpTo(
        gridScrollable.position.maxScrollExtent - 100,
      );
      await tester.pump();

      expect(spy.loadMoreCalls, greaterThanOrEqualTo(1));
    });
  });

  testWidgets("Tap on favorite icon adds character to favorites", (
    WidgetTester tester,
  ) async {
    await mockNetworkImages(() async {
      final prefs = await makePrefs();

      final spyCharacters = SpyCharactersNotifier(
        CharactersState.loaded(characters: tCharacter, hasMore: true),
      );

      final spyFavorites = SpyFavoriteNotifier();

      await pumpApp(
        tester,
        const HomePage(),
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          charactersProvider.overrideWith(() => spyCharacters),
          characterSearchProvider.overrideWith(
            () => FakeCharacterSearchNotifier(),
          ),
          favoriteProvider.overrideWith(() => spyFavorites),
        ],
      );

      await tester.pump();

      final favButton = find.byKey(
        Key('favorite_button_${tCharacters.first.id}'),
      );

      expect(favButton, findsOneWidget);

      await tester.ensureVisible(favButton);
      await tester.pump();

      await tester.tap(favButton);
      await tester.pump();

      expect(spyFavorites.toggleCalls, 1);
      expect(spyFavorites.state.length, 1);
      expect(spyFavorites.state.first.id, tCharacters.first.id);
    });
  });

  testWidgets('Tapping "Vivo" chip calls loadInitial with correct status', (
    WidgetTester tester,
  ) async {
    final prefs = await makePrefs();

    final spyCharacters = SpyCharactersNotifier(
      CharactersState.loaded(characters: tCharacters, hasMore: true),
    );

    await pumpApp(
      tester,
      const HomePage(),
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        charactersProvider.overrideWith(() => spyCharacters),
        characterSearchProvider.overrideWith(
          () => FakeCharacterSearchNotifier(),
        ),
      ],
    );

    await tester.pump();

    spyCharacters.loadInitialCalls = 0;

    final vivoChip = find.byKey(const Key('status_chip_vivo'));
    expect(vivoChip, findsOneWidget);

    await tester.tap(vivoChip);
    await tester.pump();

    expect(spyCharacters.loadInitialCalls, 1);
    expect(spyCharacters.lastStatus, mapStatus(1));
  });
  testWidgets('Tapping "Muerto" chip calls loadInitial with correct status', (
    WidgetTester tester,
  ) async {
    final prefs = await makePrefs();

    final spyCharacters = SpyCharactersNotifier(
      CharactersState.loaded(characters: tCharacters, hasMore: true),
    );

    await pumpApp(
      tester,
      const HomePage(),
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        charactersProvider.overrideWith(() => spyCharacters),
        characterSearchProvider.overrideWith(
          () => FakeCharacterSearchNotifier(),
        ),
      ],
    );

    await tester.pump();
    spyCharacters.loadInitialCalls = 0;

    final muertoChip = find.byKey(const Key('status_chip_muerto'));
    await tester.tap(muertoChip);
    await tester.pump();

    expect(spyCharacters.loadInitialCalls, 1);
    expect(spyCharacters.lastStatus, mapStatus(2));
  });
  testWidgets(
    'Tapping "Desconocido" chip calls loadInitial with correct status',
    (WidgetTester tester) async {
      final prefs = await makePrefs();

      final spyCharacters = SpyCharactersNotifier(
        CharactersState.loaded(characters: tCharacters, hasMore: true),
      );

      await pumpApp(
        tester,
        const HomePage(),
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          charactersProvider.overrideWith(() => spyCharacters),
          characterSearchProvider.overrideWith(
            () => FakeCharacterSearchNotifier(),
          ),
        ],
      );

      await tester.pump();
      spyCharacters.loadInitialCalls = 0;

      final desconocidoChip = find.byKey(const Key('status_chip_desconocido'));
      await tester.tap(desconocidoChip);
      await tester.pump();

      expect(spyCharacters.loadInitialCalls, 1);
      expect(spyCharacters.lastStatus, mapStatus(3));
    },
  );

  testWidgets("Search shows results only after debounce", (
    WidgetTester tester,
  ) async {
    await mockNetworkImages(() async {
      final prefs = await makePrefs();

      final spyCharacters = SpyCharactersNotifier(
        CharactersState.loaded(characters: tCharacters, hasMore: true),
      );

      await pumpApp(
        tester,
        const HomePage(),
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          charactersProvider.overrideWith(() => spyCharacters),
          getCharactersUseCaseProvider.overrideWithValue(
            FakeCharactersUseCase(),
          ),
        ],
      );

      await tester.pump();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Rick');
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ListTile), findsNothing);

      await tester.pump(const Duration(milliseconds: 60));

      await tester.pump();

      expect(find.byType(ListTile), findsAtLeastNWidgets(1));
    });
  });
}
