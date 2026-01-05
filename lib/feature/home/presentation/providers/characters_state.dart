import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/home/domain/usecase/characters_use_case.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/providers/characters_providers.dart';

part 'characters_state.freezed.dart';

@freezed
abstract class CharactersState with _$CharactersState {
  const factory CharactersState.initial() = _Initial;

  const factory CharactersState.loading({
    @Default([]) List<Character> characters,
  }) = _Loading;

  const factory CharactersState.loaded({
    required List<Character> characters,
    required bool hasMore,
  }) = _Loaded;

  const factory CharactersState.error({
    required String message,
    @Default([]) List<Character> characters,
  }) = _Error;
}

class CharactersNotifier extends Notifier<CharactersState> {
  late final CharactersUseCase _getCharacters;

  int _page = 1;
  bool _hasMore = true;
  bool _isFetchingMore = false;
  String? _currentStatus;

  @override
  CharactersState build() {
    _getCharacters = ref.read(getCharactersUseCaseProvider);

    return const CharactersState.initial();
  }

  Future<void> loadInitial({String? status}) async {
    _currentStatus = status;
    _page = 1;
    _hasMore = true;

    state = const CharactersState.loading();

    final result = await _getCharacters(page: _page, status: _currentStatus);

    result.fold(
      (failure) {
        state = CharactersState.error(message: failure.message);
      },
      (characters) {
        _hasMore = characters.isNotEmpty;

        state = CharactersState.loaded(
          characters: characters,
          hasMore: _hasMore,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isFetchingMore) return;

    final currentCharacters = state.maybeWhen(
      loaded: (characters, hasMore) => characters,
      orElse: () => null,
    );

    if (currentCharacters == null) return;

    _isFetchingMore = true;

    state = CharactersState.loading(characters: currentCharacters);

    _page++;

    final result = await _getCharacters(page: _page, status: _currentStatus);

    result.fold(
      (failure) {
        state = CharactersState.error(
          message: failure.message,
          characters: currentCharacters,
        );
      },
      (characters) {
        _hasMore = characters.isNotEmpty;

        state = CharactersState.loaded(
          characters: [...currentCharacters, ...characters],
          hasMore: _hasMore,
        );
      },
    );

    _isFetchingMore = false;
  }
}

final charactersProvider =
    NotifierProvider<CharactersNotifier, CharactersState>(
      CharactersNotifier.new,
    );
