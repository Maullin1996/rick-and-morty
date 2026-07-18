import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/helpers/require_auth.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/favorite/presentation/providers/favorite_provider.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/helpers/status_color.dart';

class FavoritePage extends ConsumerWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characters = ref.watch(favoriteProvider);
    final tokens = AppTokens.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: AppCardList(
        type: characters.isEmpty ? CardListType.empty : CardListType.list,
        itemCount: characters.length,
        itemBuilder: (context, index) =>
            _FavoriteCharacterTile(character: characters[index]),
        separatorBuilder: (_, __) => SizedBox(height: tokens.spacing.small),
        emptyWidget: AppStateWidget(
          type: AppStateType.empty,
          image: 'assets/images/empty.png',
          widthImage: 350,

          title: 'Aún no tienes favoritos',
          buttonChild: const Text('Explorar personajes'),
          onPressed: () => context.go('/'),
        ),
        errorWidget: const SizedBox.shrink(),
      ),
    );
  }
}

class _FavoriteCharacterTile extends ConsumerWidget {
  const _FavoriteCharacterTile({required this.character});
  final Character character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoriteProvider.select((list) => list.any((c) => c.id == character.id)),
    );
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);

    return AppCard(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 140,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(tokens.radius.medium),
              ),
              child: AppNetworkImage(
                url: character.image,
                widthImage: 120,
                heightImage: double.infinity,
                fit: BoxFit.cover,
                errorWidget: Icon(AppIcons.error, color: colors.error),
              ),
            ),
            SizedBox(width: tokens.spacing.small),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: tokens.spacing.small),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.h6(
                      character.name,
                      maxLines: 2,
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    AppText.body(character.species, color: colors.primary),
                    AppText.body(
                      character.status,
                      color: statusColor(character.status, colors),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              key: ValueKey('favorite_button_${character.id}'),
              onPressed: () {
                if (!requireAuth(context, ref)) return;
                ref.read(favoriteProvider.notifier).toggleCharacter(character);
              },
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
