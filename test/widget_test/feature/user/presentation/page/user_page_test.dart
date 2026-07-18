import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prueba_tecnica_1/feature/auth/domain/usecase/auth_use_case.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/providers/auth_provider.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/providers/auth_providers.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/favorite/presentation/providers/favorite_provider.dart';
import 'package:prueba_tecnica_1/feature/user/domain/entities/user_profile.dart';
import 'package:prueba_tecnica_1/feature/user/presentation/page/user_page.dart';
import 'package:prueba_tecnica_1/feature/user/presentation/providers/user_provider.dart';

class MockAuthUseCase extends Mock implements AuthUseCase {}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(this._loggedIn);
  final bool _loggedIn;

  @override
  bool build() => _loggedIn;
}

class FakeFavoriteNotifier extends FavoriteNotifier {
  FakeFavoriteNotifier(this._initial);
  final List<Character> _initial;

  @override
  List<Character> build() => _initial;
}

class FakeUserNotifier extends UserNotifier {
  FakeUserNotifier(this._initial);
  final UserProfile? _initial;

  @override
  UserProfile? build() => _initial;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await AtomicDesignConfig.initializeFromAsset(
      'assets/config/app_config.json',
    );
  });

  late MockAuthUseCase authUseCase;

  Widget buildSubject({
    required bool loggedIn,
    UserProfile? profile,
    List<Character> favorites = const [],
  }) {
    authUseCase = MockAuthUseCase();
    when(() => authUseCase.currentUserEmail).thenReturn('rick@citadel.com');

    return ProviderScope(
      overrides: [
        isLoggedInProvider.overrideWith(() => FakeAuthNotifier(loggedIn)),
        authUseCaseProvider.overrideWithValue(authUseCase),
        favoriteProvider.overrideWith(() => FakeFavoriteNotifier(favorites)),
        userProfileProvider.overrideWith(() => FakeUserNotifier(profile)),
      ],
      child: AppThemeProvider(
        child: MaterialApp(theme: AppThemes.dark, home: const UserPage()),
      ),
    );
  }

  testWidgets('shows the login prompt when logged out', (tester) async {
    await tester.pumpWidget(buildSubject(loggedIn: false));
    await tester.pump();

    expect(find.text('No has iniciado sesión'), findsOneWidget);
  });

  testWidgets(
    'shows the profile data, email and favorites count when logged in',
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

      await tester.pumpWidget(
        buildSubject(
          loggedIn: true,
          profile: const UserProfile(
            name: 'Rick Sanchez',
            age: 70,
            country: 'Earth',
          ),
          favorites: [character],
        ),
      );
      await tester.pump();

      expect(find.text('Rick Sanchez'), findsOneWidget);
      expect(find.text('70 años'), findsOneWidget);
      expect(find.text('Earth'), findsOneWidget);
      expect(find.text('rick@citadel.com'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    },
  );

  testWidgets('shows placeholders when the profile has not been filled yet', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(loggedIn: true));
    await tester.pump();

    expect(find.text('No especificado'), findsNWidgets(2));
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('tapping the edit icon opens the edit profile sheet', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(loggedIn: true));
    await tester.pump();

    await tester.tap(find.byKey(const Key('edit_profile_button')));
    await tester.pumpAndSettle();

    expect(find.text('Editar perfil'), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);
  });
}
