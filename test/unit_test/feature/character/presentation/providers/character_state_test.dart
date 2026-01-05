import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/character/domain/usecase/character_use_case.dart';
import 'package:prueba_tecnica_1/feature/character/presentation/providers/character_provider.dart';
import 'package:prueba_tecnica_1/feature/character/presentation/providers/character_state.dart';

class MockCharacterUseCase extends Mock implements CharacterUseCase {}

void main() {
  late ProviderContainer container;
  late MockCharacterUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockCharacterUseCase();

    container = ProviderContainer(
      overrides: [getCharacterUseCaseProvider.overrideWithValue(mockUseCase)],
    );
  });
  tearDown(() {
    container.dispose();
  });

  final tCharacter = Character(
    id: 1,
    name: 'Rick',
    gender: 'Male',
    status: 'Alive',
    species: 'Human',
    image: 'url',
    origin: Origin(name: 'Earth', url: 'url'),
    episodes: ['1'],
  );

  test('initial state should be AsyncLoading', () {
    when(
      () => mockUseCase.call(id: 1),
    ).thenAnswer((_) async => Right(tCharacter));

    final state = container.read(characterProvider(1));

    expect(state, isA<AsyncLoading>());
  });

  test('should emit data when usecase succeeds', () async {
    when(
      () => mockUseCase.call(id: 1),
    ).thenAnswer((_) async => Right(tCharacter));

    final result = await container.read(characterProvider(1).future);

    expect(result, tCharacter);

    verify(() => mockUseCase.call(id: 1)).called(1);
  });

  test('refresh should call usecase again', () async {
    when(
      () => mockUseCase.call(id: 1),
    ).thenAnswer((_) async => Right(tCharacter));

    // Primera carga
    await container.read(characterProvider(1).future);

    final notifier = container.read(characterProvider(1).notifier);

    // Refresh
    await notifier.refresh();

    verify(() => mockUseCase.call(id: 1)).called(2);
  });
}
