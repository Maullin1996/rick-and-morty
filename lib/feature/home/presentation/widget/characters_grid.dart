import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/helpers/require_auth.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/favorite/presentation/providers/favorite_provider.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/widget/character_card.dart';

class CharactersGrid extends ConsumerWidget {
  final List<Character> characters;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;

  const CharactersGrid({
    super.key,
    required this.characters,
    required this.isLoading,
    required this.onRetry,
    required this.onLoadMore,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void addFavorite(Character character) {
      if (!requireAuth(context, ref)) return;
      ref.read(favoriteProvider.notifier).toggleCharacter(character);
    }

    final favorites = ref.watch(favoriteProvider);
    final favoriteIds = favorites.map((e) => e.id).toSet();
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);

    final isFirstLoad = isLoading && characters.isEmpty;
    final hasFatalError = errorMessage != null && characters.isEmpty;
    final hasPartialError = errorMessage != null && characters.isNotEmpty;
    final isEmptyResult =
        !isLoading && errorMessage == null && characters.isEmpty;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 300) {
          onLoadMore();
        }
        return false;
      },
      child: Stack(
        children: [
          AppGridView(
            key: const Key('characters_grid'),
            type: isFirstLoad
                ? GridViewType.loading
                : hasFatalError
                ? GridViewType.error
                : isEmptyResult
                ? GridViewType.empty
                : GridViewType.list,
            childAspectRatio: 0.65,
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];

              return CharacterCard(
                character: character,
                isFavorite: favoriteIds.contains(character.id),
                onPressed: () => addFavorite(character),
              );
            },
            emptyWidget: AppStateWidget(
              type: AppStateType.empty,
              icon: Icons.travel_explore,
              title: 'No se encontraron personajes',
              buttonChild: const Text('Reintentar'),
              onPressed: onRetry,
            ),
            errorWidget: AppStateWidget(
              type: AppStateType.error,
              icon: AppIcons.error,
              title: errorMessage ?? 'Ocurrió un error',
              buttonChild: const Text('Reintentar'),
              onPressed: onRetry,
            ),
          ),

          if (isLoading && characters.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(color: colors.primary),
              ),
            ),

          if (hasPartialError)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Material(
                color: colors.error,
                borderRadius: BorderRadius.circular(tokens.radius.medium),
                child: Padding(
                  padding: EdgeInsets.all(tokens.spacing.xSmall),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: colors.onError),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
