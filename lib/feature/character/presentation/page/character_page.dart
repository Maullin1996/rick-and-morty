import 'package:atomic_design/design_system.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/helpers/require_auth.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/character/presentation/helpers/episode_number.dart';
import 'package:prueba_tecnica_1/feature/character/presentation/providers/character_state.dart';
import 'package:prueba_tecnica_1/feature/character/presentation/widgets/description_widget.dart';
import 'package:prueba_tecnica_1/feature/favorite/presentation/providers/favorite_provider.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/helpers/status_color.dart';

class CharacterPage extends HookConsumerWidget {
  final int id;

  const CharacterPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(characterProvider(id));

    return state.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          Scaffold(body: Center(child: Text(error.toString()))),
      data: (character) => Scaffold(
        body: SafeArea(child: _CharacterView(character: character)),
      ),
    );
  }
}

class _CharacterView extends ConsumerWidget {
  const _CharacterView({required this.character});
  final Character character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoriteProvider.select(
        (favorites) => favorites.any((c) => c.id == character.id),
      ),
    );
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Center(
                child: Hero(
                  tag: character.id,
                  child: CachedNetworkImage(
                    imageUrl: character.image,
                    placeholder: (_, __) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (_, __, ___) =>
                        Icon(AppIcons.error, color: colors.error),
                  ),
                ),
              ),
              Positioned(child: BackButton(color: colors.primary)),
            ],
          ),
          const Divider(thickness: 2),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.spacing.small),
            child: Row(
              children: [
                Expanded(
                  child: AppText.h3(character.name, color: colors.primary),
                ),
                IconButton(
                  key: const Key('favorite_button'),
                  onPressed: () {
                    if (!requireAuth(context, ref)) return;
                    ref
                        .read(favoriteProvider.notifier)
                        .toggleCharacter(character);
                  },
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 30,
                  ),
                  color: colors.primary,
                ),
              ],
            ),
          ),
          const Divider(thickness: 2),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.spacing.small),
            child: AppText.h5(
              character.status,
              color: statusColor(character.status, colors),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(thickness: 2),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.spacing.small),
            child: Column(
              children: [
                DescriptionWidget(
                  icon: Icons.animation_outlined,
                  firstText: 'Especie:',
                  secondText: character.species,
                ),
                SizedBox(height: tokens.spacing.small),
                DescriptionWidget(
                  icon: Icons.person_2_rounded,
                  firstText: 'Género:',
                  secondText: character.gender,
                ),
                SizedBox(height: tokens.spacing.small),
                DescriptionWidget(
                  icon: Icons.location_on,
                  firstText: 'Origen:',
                  secondText: character.origin.name,
                ),
              ],
            ),
          ),
          const Divider(thickness: 2),
          Center(
            child: AppText.h5(
              'Episodios',
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: tokens.spacing.small),
          ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: tokens.spacing.small),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: character.episodes.length,
            itemBuilder: (context, index) {
              final String episode = character.episodes[index];

              return Row(
                children: [
                  Icon(Icons.movie, size: 25, color: colors.primary),
                  SizedBox(width: tokens.spacing.small),
                  Expanded(
                    child: AppText.bodyLg(
                      'Episodio ${episodeNumber(episode)}',
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              );
            },
            separatorBuilder: (context, index) =>
                SizedBox(height: tokens.spacing.xSmall),
          ),
        ],
      ),
    );
  }
}
