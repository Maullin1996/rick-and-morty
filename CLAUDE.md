# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app (`prueba_tecnica_1`) consuming the public Rick and Morty API (`https://rickandmortyapi.com/api`): character list with pagination/infinite scroll, debounced search, status filter, character detail, and locally persisted favorites (gated behind login). Dark, sci-fi themed UI built on a custom design-system package (`atomic_design`). Bottom nav with three tabs (Home / Favoritos / Usuario) plus Login/Register screens backed by real `FirebaseAuth` (email/password + Google) — see **Auth & Firebase** below.

## Commands

```bash
flutter pub get                                              # install deps
flutter analyze                                              # lint (must be clean — CI blocks on this)
flutter test                                                 # run all tests
flutter test test/unit_test/feature/home/domain/usecase/characters_use_case_test.dart   # single file
flutter test --plain-name "Search shows results only after debounce"                    # single test by name
dart run build_runner build --delete-conflicting-outputs     # regenerate freezed/json_serializable code after editing entities/states
flutter run                                                  # run the app
flutterfire configure -p proyecto-final-2-167bf --platforms=android,ios -y   # re-fetch Firebase config if apps/project change
```

CI (`.github/workflows/ci.yml`) runs `flutter analyze` and `flutter test` on every PR/push to `main`/`develop`/`release`, then builds Android AAB and iOS (no-codesign) if tests pass. Uses Flutter `3.44.6` (required by the atomic_design design-system dependency, which needs Dart >=3.11.1).

On Windows, expect a noisy but non-fatal Kotlin stack trace on Android builds — `Could not close incremental caches ... different roots` — whenever the pub cache and the project live on different drive letters. The APK still builds and installs; it's a known Kotlin/Gradle incremental-compiler bug, not a real failure.

## Architecture

Clean Architecture, organized **by feature**, not by layer. Each feature under `lib/feature/<name>/` has its own `data/`, `domain/`, `presentation/` (not every feature has all three — only `favorite` lacks a `data` layer of its own: it reuses `character`'s entity and persists through `core/services`). `auth` follows the full stack like `home`/`character` (datasource -> repository -> use case), just with no domain **entity** — a `bool` session flag doesn't need one, see **Auth & Firebase**.

- **domain**: entities (`Character`, built with `freezed`), abstract repositories, use cases (thin wrappers that just call the repository).
- **data**: remote datasources (raw HTTP + JSON decoding into `*Model` via `json_serializable`), a `*_adapter.dart` that maps `Model -> Entity` (e.g. `character_adapter.dart`), and repository implementations that catch typed exceptions and return `Either<Failure, T>` (via `dartz`).
- **presentation**: Riverpod (`hooks_riverpod`) `Notifier`s + `@freezed` sealed states, pages (`ConsumerStatefulWidget`/`HookConsumerWidget`), widgets.

Existing features: `home` (list/search/filter), `character` (detail), `favorite` (persisted favorites, no remote data layer, gated behind login), `auth` (Login/Register screens backed by real `FirebaseAuth`), `user` (bottom-nav "Usuario" tab, placeholder profile page).

### Data flow
UI widget -> reads a Riverpod provider -> `Notifier` calls a `UseCase` -> `UseCase` calls the abstract `Repository` -> concrete `RepositoryImpl` calls a remote `Datasource` -> `HttpClient` -> JSON -> `Model` -> adapter maps to domain `Entity` -> `Either<Failure, Entity>` bubbles back up -> `Notifier` folds it into a `@freezed` state (`initial/loading/loaded/error`) -> widget re-renders via `state.when(...)`.

### Error handling
Two-level typed error system, not raw exceptions/strings:
- `core/error/exceptions.dart`: `NetworkException`, `ServerException`, `ParsingException`, `CacheException`, `UnknownException` — thrown from datasource/HTTP layer.
- `core/error/failure.dart` + `error_mapper.dart`: exceptions get mapped to matching `Failure` types, which carry a user-facing message pulled from `core/utils/constants.dart` (`ErrorMessages`, in Spanish).
- `core/http/http_client.dart` wraps `package:http`, applies a 5s timeout, translates `SocketException`/`TimeoutException` into `NetworkException`, validates status codes, and retries once automatically on `NetworkException`.

### State management conventions
- Riverpod `Notifier` (not `StateNotifier`) + `@freezed` union states with named factories `initial/loading/loaded/error`, consumed via `state.when(...)` in the UI.
- Each feature wires its own DI chain of plain `Provider`s in a `*_providers.dart` file (http client -> datasource -> repository -> use case). Note: `home` and `character` each declare their **own** `httpClientProvider` (separate `http.Client()` instances) — this is existing duplication, not a shared core provider; be aware when adding a feature that also needs HTTP.
- Pagination state (`_page`, `_hasMore`, `_isFetchingMore`) is held as private fields on the `Notifier`, not in the `@freezed` state itself.
- Search (`character_search_state.dart`) debounces input with a `Timer` (350ms) inside the notifier, ranks results client-side (exact match > startsWith > contains), and caps results at 5.
- `isLoggedInProvider` (`feature/auth/presentation/providers/auth_provider.dart`) is a plain `Notifier<bool>` — no `@freezed`, no loading/error states (a deliberate simplification, unlike `character`/`home`'s `AsyncNotifier`/`@freezed` states). `AuthNotifier.build()` reads `AuthUseCase.isLoggedIn` (backed by `FirebaseAuth.instance.currentUser`) and keeps it in sync via `AuthUseCase.authStateChanges` (cancelled through `ref.onDispose`), so **any widget test that renders a page reading this provider must override it** (e.g. `isLoggedInProvider.overrideWith(() => FakeAuthNotifier())`) or `build()` throws `[core/no-app] No Firebase App '[DEFAULT]' has been created` — this bit every `home_page_test.dart` case once the real wiring landed, not just the ones that tap a favorite toggle.

### Persistence
Favorites are stored via `core/services/shared_preferences_service.dart` (JSON-encoded list of characters in `SharedPreferences`), injected through `shared_preferences_services_provider.dart`. `FavoriteNotifier` (`feature/favorite`) keeps an in-memory list synced with storage on every add/remove. Every favorite-toggle call site (`characters_grid.dart`, `character_page.dart`, `favorite_page.dart`) is gated by `requireAuth(context, ref)` (`feature/auth/presentation/helpers/require_auth.dart`) — without a session it shows an `AppSnackBar` with an "Iniciar sesión" action instead of toggling.

### Routing
`go_router` config lives entirely in `core/routes/routes.dart`. The three bottom-nav destinations (`/`, `/favorite`, `/user`) are branches of a `StatefulShellRoute.indexedStack`, rendered inside `MainShellPage` (`core/routes/main_shell_page.dart`), which owns the `AppBottomNavBar`. `/character`, `/login`, and `/register` are **top-level sibling routes outside the shell**, so they cover the full screen (no bottom nav) when opened.

Navigate to those three with `context.push(...)`, never `context.go(...)` — `push` stacks on top of the shell's root `Navigator` so the system back button returns to the shell where you left it; `go` rebuilds the location from scratch and drops the shell, which makes the back button exit the app. `/character` still expects `extra` to be an `int` id, cast with `state.extra as int`, not a path param.

## Design system

UI is built entirely on `atomic_design` (own package, path `D:\documentos\mobile_apps\atomic_design`, consumed here as a **git dependency** — `pubspec.yaml` points at `https://github.com/Maullin1996/atomic_design.git@main`, not a local `path:`, so CI can resolve it). `import 'package:atomic_design/design_system.dart'` is the single entry point for every atom/molecule/organism (`AppText`, `AppButtons`, `AppInputText`, `AppCard`, `AppNetworkImage`, `AppGridView`, `AppCardList`, `AppStateWidget`, `AppBottomNavBar`, `AppSearchBar`/`AppResultSearchBar`, `AppSnackBar`, etc.) — there is no bespoke `SciFiColors`/theme code left in this app; the old `core/tokens/scifi_colors.dart` was deleted once the migration landed.

- Tokens (colors, typography, spacing, radius, plus five responsive breakpoints) live in `assets/config/app_config.json`, mapping the original sci-fi palette onto the package's semantic slots (`primary` = neon cyan, `success`/`error`/`warning` used for character status, etc.). `light` and `dark` blocks are identical — the app only ever runs in dark mode (`themeMode: ThemeMode.dark` in `main_app.dart`) but the config schema requires both.
- `main.dart` calls `AtomicDesignConfig.initializeFromAsset('assets/config/app_config.json')` before `runApp`; `main_app.dart` wraps `MaterialApp.router` in `AppThemeProvider` and passes `theme: AppThemes.light, darkTheme: AppThemes.dark`. Any widget using tokens needs `AppThemeProvider` above it in the tree — widget tests that pump a page standalone must replicate this setup (see **Tests**).
- Status color (Vivo/Muerto/Desconocido → success/error/warning) is centralized in `feature/home/presentation/helpers/status_color.dart` and reused across `character_card.dart`, `character_page.dart`, and the favorites list tile — don't hardcode a color per screen.
- `AppNetworkImage`/`AppCard` show a `Shimmer.fromColors` loading skeleton with a **looping** animation — never `pumpAndSettle()` a widget tree that renders one, it will time out regardless of how fast the network mock resolves. Use bounded `pump()` calls instead (see `favorite_page_test.dart`).

## Auth & Firebase

Firebase project `proyecto-final-2-167bf` is connected (`lib/firebase_options.dart`, `android/app/google-services.json`, `firebase.json`, generated via `flutterfire configure`; `firebase_core`/`firebase_auth`/`google_sign_in` are in `pubspec.yaml`), and `main.dart` calls `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` before anything else.

**Auth is wired to real Firebase**, through the same layered stack as `home`/`character`:
- `feature/auth/data/datasources/auth_remote_datasource_impl.dart` is the only place that touches the Firebase/Google SDKs directly. `FirebaseAuth`/`GoogleSignIn` are injected via optional constructor params (defaulting to `.instance`), mirroring how `CharacterRemoteDatasourceImpl` takes an injectable `HttpClient` — this is what makes it mockable in `auth_repository_impl_test.dart`. `signInWithEmailAndPassword`/`createUserWithEmailAndPassword` wrap `FirebaseAuth`; `signInWithGoogle` lazily calls `GoogleSignIn.instance.initialize(...)` (once per app run) then `.authenticate()`, exchanges the resulting `idToken` for a `GoogleAuthProvider.credential`, and signs in to Firebase with it. All three throw `AuthException` (`core/error/exceptions.dart`) on `FirebaseAuthException`/`GoogleSignInException`, with the Firebase error code mapped to a Spanish message via `data/helpers/auth_error_mapper.dart` (`mapFirebaseAuthErrorCode`) against `AuthErrorMessages` in `core/utils/constants.dart`.
- `feature/auth/data/repositories/auth_repository_impl.dart` catches `AuthException` and returns `Either<Failure, Unit>` (`AuthFailure`, also new in `core/error/failure.dart`/`error_mapper.dart`), same shape as `CharacterRepositoryImpl`.
- `feature/auth/domain/repositories/auth_repository.dart` + `domain/usecase/auth_use_case.dart` are thin, same convention as `CharacterRepository`/`CharacterUseCase` — no domain **entity** though, since there's no meaningful domain data beyond a `bool` session flag and a `Stream<bool>`.
- `AuthNotifier` (`presentation/providers/auth_provider.dart`) only talks to `AuthUseCase` (wired in `presentation/providers/auth_providers.dart`, the DI chain file, named like `characters_providers.dart`) and folds `Either` results: `Left` → `throw AuthException(failure.message)`, `Right` → `state = true`. `LoginPage`/`RegisterPage` catch `AuthException` (now imported from `core/error/exceptions.dart`, not from `auth_provider.dart`) and show it with `AppSnackBar.show(type: SnackBarType.error, ...)`, tracking an `_isSubmitting` bool to disable the buttons / show `AppButtons(isLoading: ...)` mid-request.
- `GoogleSignIn` v7's API (`google_sign_in: ^7.2.0`) is `initialize()` + `authenticate()`, not the old `signIn()`; the required `serverClientId` (Android's OAuth **web** client, `client_type: 3` in `android/app/google-services.json`) is hardcoded as `_googleWebClientId` in `auth_remote_datasource_impl.dart`. On iOS it also passes `clientId: DefaultFirebaseOptions.ios.iosClientId`.
- A user canceling the Google picker (`GoogleSignInExceptionCode.canceled`) returns silently instead of throwing, all the way up through the repository/use case (`Right(unit)` is never reached, but nothing throws either) — `LoginPage._continueWithGoogle` handles this by only popping the route when `ref.read(isLoggedInProvider)` is actually `true` afterward, not just on "no exception thrown".

`ios/Runner/GoogleService-Info.plist` is now present (fetched from the Firebase console; `flutterfire configure` never downloaded it), with a `CLIENT_ID` matching `DefaultFirebaseOptions.ios.iosClientId`. **Still missing**: the `REVERSED_CLIENT_ID` from that file isn't registered as a `CFBundleURLTypes` URL scheme in `ios/Runner/Info.plist` — without it the Google OAuth redirect can't return to the app, so Google Sign-In on iOS is untested/likely broken until that's added. Desktop builds (Windows/macOS/Linux) have no native Google Sign-In implementation; tapping the Google button there is caught by the generic `catch (_)` in `AuthRemoteDatasourceImpl.signInWithGoogle` and surfaces as `AuthErrorMessages.googleSignInFailed` rather than crashing, but is otherwise unsupported.

Login/Register (`feature/auth/presentation/page/`) are built from `atomic_design` atoms directly (`AppInputText`, `AppButtons`, `AppText`), **not** the package's `AppLoginForm` organism — that organism has a real bug (`onGoogle`/`onFacebook` render each other's SVG icon), so building by hand also sidesteps it. Google sign-in only appears on Login, not Register (confirmed product decision, not an oversight).

## Linting

`analysis_options.yaml` extends `flutter_lints` plus `dart_code_linter` with custom metrics (cyclomatic complexity ≤ 20, max 4 params, max nesting 5) and extra rules (`avoid-dynamic`, `no-empty-block`, `prefer-conditional-expressions`, `prefer-moving-to-variable`, etc.). Metrics are excluded for `test/**`. Keep `flutter analyze` clean before considering a change done.

## Tests

- `test/unit_test/` mirrors `lib/feature/.../` structure: datasources, repositories, use cases, providers/notifiers, plus `core` (error mapper, http client, shared prefs service).
- `test/widget_test/` covers home, character, and favorite pages using fakes/spies of the real `Notifier` classes (e.g. `FakeCharactersNotifier`, `SpyCharactersNotifier`) wired in via Riverpod's `overrideWith`, and `mocktail_image_network`'s `mockNetworkImages` to stub `CachedNetworkImage`/`NetworkImage` calls.
- Every widget test that pumps a real page needs, in `setUpAll`: `await AtomicDesignConfig.initializeFromAsset('assets/config/app_config.json')`, and the pumped widget wrapped in `AppThemeProvider` (plus `theme: AppThemes.dark` on the `MaterialApp`/`MaterialApp.router`) — without both, any `atomic_design` widget throws (`AppTokens.of`/`AppColors.of` need the provider; the config singleton needs to be initialized once).
- `AuthNotifier.build()` now calls real `FirebaseAuth` (see **Auth & Firebase**), so **every** widget test that pumps a page reading `isLoggedInProvider` — not just ones that tap a favorite toggle — needs `isLoggedInProvider.overrideWith(() => FakeAuthNotifier(...))` (a local `AuthNotifier` subclass overriding only `build()`) in its `ProviderScope` overrides, or `build()` throws `[core/no-app] No Firebase App...` since Firebase is never initialized in the test environment. `character_page_test.dart` also has a `loggedIn: false` case proving the gate itself (no toggle, no icon change).
- Don't `pumpAndSettle()` a tree containing `AppNetworkImage`/`AppCard` — see the shimmer-loop note under **Design system**. Use `mockNetworkImages(() async { ... })` (from `mocktail_image_network`) plus explicit bounded `pump()` calls instead.
- `test/fixtures/` holds JSON fixtures (`character.json`, `character_list.json`) loaded via `fixture_reader.dart`.
