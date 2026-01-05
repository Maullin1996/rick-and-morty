import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/character/presentation/page/character_page.dart';
import 'package:prueba_tecnica_1/feature/character/presentation/providers/character_state.dart';
import 'package:prueba_tecnica_1/feature/favorite/presentation/providers/favorite_provider.dart';

class SpyFavoriteNotifier extends FavoriteNotifier {
  int toggleCalls = 0;

  @override
  List<Character> build() => [];

  @override
  void toggleCharacter(Character character) {
    toggleCalls++;
    state = [character, ...state];
  }
}

class FakeCharacterNotifier extends CharacterNotifier {
  final Future<Character> Function() _future;

  FakeCharacterNotifier(this._future) : super(0);

  @override
  Future<Character> build() => _future();
}

Override characterOverride({
  Character? data,
  Object? error,
  bool loading = false,
}) {
  return characterProvider.overrideWith(() {
    if (loading) {
      final completer = Completer<Character>();

      return FakeCharacterNotifier(() => completer.future);
    }

    if (error != null) {
      return FakeCharacterNotifier(() => Future.error(error));
    }

    return FakeCharacterNotifier(() => Future.value(data!));
  });
}

Widget createWidget({
  required Override characterOverride,
  SpyFavoriteNotifier? spy,
}) {
  return ProviderScope(
    overrides: [
      characterOverride,
      favoriteProvider.overrideWith(() => spy ?? SpyFavoriteNotifier()),
    ],
    child: const MaterialApp(home: CharacterPage(id: 1)),
  );
}

void main() {
  late Character character;

  setUp(() {
    character = Character(
      id: 1,
      name: 'Rick Sanchez',
      gender: 'Male',
      status: 'Alive',
      species: 'Human',
      image: 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
      origin: Origin(name: 'Earth', url: ''),
      episodes: [
        'https://rickandmortyapi.com/api/episode/1',
        'https://rickandmortyapi.com/api/episode/2',
      ],
    );
  });

  testWidgets("shows loading", (WidgetTester tester) async {
    await tester.pumpWidget(
      createWidget(characterOverride: characterOverride(loading: true)),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets("shows error", (WidgetTester tester) async {
    await tester.pumpWidget(
      createWidget(
        characterOverride: characterOverride(error: Exception('Boom')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Boom'), findsOneWidget);
  });

  testWidgets("shows character data", (tester) async {
    await tester.pumpWidget(
      createWidget(characterOverride: characterOverride(data: character)),
    );

    await tester.pump();

    expect(find.text('Rick Sanchez'), findsOneWidget);
  });

  testWidgets('toggles favorite', (tester) async {
    final spy = SpyFavoriteNotifier();

    await tester.pumpWidget(
      createWidget(
        characterOverride: characterOverride(data: character),
        spy: spy,
      ),
    );

    await tester.pump(); // deja pasar el AsyncNotifier

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.byKey(const Key('favorite_button')));
    await tester.pump();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(spy.toggleCalls, 1);
  });
}
