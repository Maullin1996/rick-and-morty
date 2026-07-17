# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app (`prueba_tecnica_1`) consuming the public Rick and Morty API (`https://rickandmortyapi.com/api`): character list with pagination/infinite scroll, debounced search, status filter, character detail, and locally persisted favorites. Dark, sci-fi themed UI.

## Commands

```bash
flutter pub get                                              # install deps
flutter analyze                                              # lint (must be clean — CI blocks on this)
flutter test                                                 # run all tests
flutter test test/unit_test/feature/home/domain/usecase/characters_use_case_test.dart   # single file
flutter test --plain-name "Search shows results only after debounce"                    # single test by name
dart run build_runner build --delete-conflicting-outputs     # regenerate freezed/json_serializable code after editing entities/states
flutter run                                                  # run the app
```

CI (`.github/workflows/ci.yml`) runs `flutter analyze` and `flutter test` on every PR/push to `main`/`develop`/`release`, then builds Android AAB and iOS (no-codesign) if tests pass. Uses Flutter `3.38.5`.

## Architecture

Clean Architecture, organized **by feature**, not by layer. Each feature under `lib/feature/<name>/` has its own `data/`, `domain/`, `presentation/` (not every feature has all three — `favorite` has no `data` layer of its own, it reuses `character`'s entity and persists through `core/services`).

- **domain**: entities (`Character`, built with `freezed`), abstract repositories, use cases (thin wrappers that just call the repository).
- **data**: remote datasources (raw HTTP + JSON decoding into `*Model` via `json_serializable`), a `*_adapter.dart` that maps `Model -> Entity` (e.g. `character_adapter.dart`), and repository implementations that catch typed exceptions and return `Either<Failure, T>` (via `dartz`).
- **presentation**: Riverpod (`hooks_riverpod`) `Notifier`s + `@freezed` sealed states, pages (`ConsumerStatefulWidget`/`HookConsumerWidget`), widgets.

Existing features: `home` (list/search/filter), `character` (detail), `favorite` (persisted favorites, no remote data layer).

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

### Persistence
Favorites are stored via `core/services/shared_preferences_service.dart` (JSON-encoded list of characters in `SharedPreferences`), injected through `shared_preferences_services_provider.dart`. `FavoriteNotifier` (`feature/favorite`) keeps an in-memory list synced with storage on every add/remove.

### Routing
`go_router` config lives entirely in `core/routes/routes.dart`. Routes: `/` (home), `/favorite`, `/character` (detail — expects `extra` to be an `int` id, cast with `state.extra as int`, not a path param).

## Linting

`analysis_options.yaml` extends `flutter_lints` plus `dart_code_linter` with custom metrics (cyclomatic complexity ≤ 20, max 4 params, max nesting 5) and extra rules (`avoid-dynamic`, `no-empty-block`, `prefer-conditional-expressions`, `prefer-moving-to-variable`, etc.). Metrics are excluded for `test/**`. Keep `flutter analyze` clean before considering a change done.

## Tests

- `test/unit_test/` mirrors `lib/feature/.../` structure: datasources, repositories, use cases, providers/notifiers, plus `core` (error mapper, http client, shared prefs service).
- `test/widget_test/` covers the three pages (home, character, favorite) using fakes/spies of the real `Notifier` classes (e.g. `FakeCharactersNotifier`, `SpyCharactersNotifier`) wired in via Riverpod's `overrideWith`, and `mocktail_image_network`'s `mockNetworkImages` to stub `CachedNetworkImage`/`NetworkImage` calls.
- `test/fixtures/` holds JSON fixtures (`character.json`, `character_list.json`) loaded via `fixture_reader.dart`.
