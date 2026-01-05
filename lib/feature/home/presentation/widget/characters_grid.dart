import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/favorite/presentation/providers/favorite_provider.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/widget/character_card.dart';

class CharactersGrid extends ConsumerWidget {
  final ScrollController controller;
  final List<Character> characters;
  final bool isLoading;
  final String? errorMessage;

  const CharactersGrid({
    super.key,
    required this.controller,
    required this.characters,
    required this.isLoading,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void addFavorite(Character character) {
      ref.read(favoriteProvider.notifier).toggleCharacter(character);
    }

    final favorites = ref.watch(favoriteProvider);
    final favoriteIds = favorites.map((e) => e.id).toSet();

    return Stack(
      children: [
        GridView.builder(
          key: const Key('characters_grid'),
          controller: controller,
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.65,
          ),
          itemCount: characters.length,
          itemBuilder: (context, index) {
            final character = characters[index];

            return CharacterCard(
              character: character,
              isFavorite: favoriteIds.contains(character.id),
              onPressed: () => addFavorite(character),
            );
          },
        ),

        if (isLoading)
          const Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(child: CircularProgressIndicator()),
          ),

        if (errorMessage != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
