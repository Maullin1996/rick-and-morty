import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/core/services/shared_preferences_services_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:prueba_tecnica_1/feature/favorite/presentation/page/favorite_page.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';

Future<SharedPreferences> makePrefs({List<Character>? initialFavorites}) {
  final Map<String, Object> data = {};

  if (initialFavorites != null) {
    data['favorites'] = jsonEncode(
      initialFavorites.map((e) => e.toJson()).toList(),
    );
  }

  SharedPreferences.setMockInitialValues(data);

  return SharedPreferences.getInstance();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'removes character from favorites when favorite button is pressed',
    (tester) async {
      final character = Character(
        id: 1,
        name: 'Rick Sanchez',
        gender: 'Male',
        status: 'Alive',
        species: 'Human',
        image: 'url',
        origin: Origin(name: 'Earth', url: ''),
        episodes: ['1'],
      );

      final prefs = await makePrefs(initialFavorites: [character]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(home: FavoritePage()),
        ),
      );

      await tester.pumpAndSettle();

      // El item existe
      expect(find.text('Rick Sanchez'), findsOneWidget);

      // 🔑 Tocamos EXPLÍCITAMENTE el botón correcto
      await tester.tap(find.byKey(const Key('favorite_button_1')));
      await tester.pumpAndSettle();

      // El item desapareció
      expect(find.text('Rick Sanchez'), findsNothing);
    },
  );
}
