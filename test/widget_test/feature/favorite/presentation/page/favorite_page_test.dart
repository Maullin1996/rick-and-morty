import 'dart:convert';

import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:prueba_tecnica_1/core/services/shared_preferences_services_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:prueba_tecnica_1/feature/auth/presentation/providers/auth_provider.dart';
import 'package:prueba_tecnica_1/feature/favorite/presentation/page/favorite_page.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';

class FakeAuthNotifier extends AuthNotifier {
  @override
  bool build() => true;
}

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

  setUpAll(() async {
    await AtomicDesignConfig.initializeFromAsset(
      'assets/config/app_config.json',
    );
  });

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

      await mockNetworkImages(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              isLoggedInProvider.overrideWith(() => FakeAuthNotifier()),
            ],
            child: AppThemeProvider(
              child: MaterialApp(
                theme: AppThemes.dark,
                home: const FavoritePage(),
              ),
            ),
          ),
        );

        // No usamos pumpAndSettle: AppNetworkImage muestra un shimmer con una
        // animación en loop mientras carga, que nunca "se asienta".
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // El item existe
        expect(find.text('Rick Sanchez'), findsOneWidget);

        // 🔑 Tocamos EXPLÍCITAMENTE el botón correcto
        await tester.tap(find.byKey(const Key('favorite_button_1')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        // El item desapareció
        expect(find.text('Rick Sanchez'), findsNothing);
      });
    },
  );
}
