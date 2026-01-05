import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/character/presentation/providers/character_provider.dart';

class CharacterNotifier extends AsyncNotifier<Character> {
  CharacterNotifier(this.id);
  final int id;

  @override
  Future<Character> build() async {
    ref.keepAlive();
    final useCase = ref.read(getCharacterUseCaseProvider);

    final result = await useCase.call(id: id);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (character) => character,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final characterProvider =
    AsyncNotifierProvider.family<CharacterNotifier, Character, int>(
      (id) => CharacterNotifier(id),
    );
