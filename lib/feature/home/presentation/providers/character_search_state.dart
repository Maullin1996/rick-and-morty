import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/home/domain/usecase/characters_use_case.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/providers/characters_providers.dart';
part 'character_search_state.freezed.dart';

@freezed
class CharacterSearchState with _$CharacterSearchState {
  const factory CharacterSearchState.initial() = _Initial;
  const factory CharacterSearchState.loading() = _Loading;
  const factory CharacterSearchState.loaded({
    required List<Character> results,
  }) = _Loaded;
  const factory CharacterSearchState.error({required String message}) = _Error;
}

class CharacterSearchNotifier extends Notifier<CharacterSearchState> {
  late final CharactersUseCase _getCharacters;
  Timer? _debounce;

  @override
  CharacterSearchState build() {
    _getCharacters = ref.read(getCharactersUseCaseProvider);

    ref.onDispose(() {
      _debounce?.cancel();
    });

    return const CharacterSearchState.initial();
  }

  void search(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      state = const CharacterSearchState.initial();

      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _performSearch(query),
    );
  }

  Future<void> _performSearch(String query) async {
    state = const CharacterSearchState.loading();

    final result = await _getCharacters(page: 1, name: query);

    result.fold(
      (failure) {
        state = CharacterSearchState.error(message: failure.message);
      },
      (characters) {
        final queryLower = query.toLowerCase();

        final sorted = [...characters]
          ..sort((a, b) {
            final aName = a.name.toLowerCase();
            final bName = b.name.toLowerCase();

            // 1️⃣ match exacto
            if (aName == queryLower && bName != queryLower) return -1;
            if (bName == queryLower && aName != queryLower) return 1;

            // 2️⃣ empieza por el texto
            final aStarts = aName.startsWith(queryLower);
            final bStarts = bName.startsWith(queryLower);
            if (aStarts && !bStarts) return -1;
            if (bStarts && !aStarts) return 1;

            // 3️⃣ contiene el texto
            final aContains = aName.contains(queryLower);
            final bContains = bName.contains(queryLower);
            if (aContains && !bContains) return -1;
            if (bContains && !aContains) return 1;

            return 0;
          });

        state = CharacterSearchState.loaded(results: sorted.take(5).toList());
      },
    );
  }

  void clear() {
    _debounce?.cancel();
    state = const CharacterSearchState.initial();
  }
}

final characterSearchProvider =
    NotifierProvider<CharacterSearchNotifier, CharacterSearchState>(
      CharacterSearchNotifier.new,
    );
