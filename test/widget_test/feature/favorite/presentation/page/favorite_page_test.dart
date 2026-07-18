import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/providers/auth_provider.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/favorite/presentation/page/favorite_page.dart';
import 'package:prueba_tecnica_1/feature/favorite/presentation/providers/favorite_provider.dart';

class FakeAuthNotifier extends AuthNotifier {
  @override
  bool build() => true;
}

class FakeFavoriteNotifier extends FavoriteNotifier {
  FakeFavoriteNotifier(this._initial);
  final List<Character> _initial;

  @override
  List<Character> build() => _initial;

  @override
  void addCharacter(Character character) {
    state = [character, ...state];
  }

  @override
  void removeCharacter(int id) {
    state = state.where((c) => c.id != id).toList();
  }
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

      await mockNetworkImages(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              favoriteProvider.overrideWith(
                () => FakeFavoriteNotifier([character]),
              ),
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
