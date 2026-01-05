import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/core/tokens/scifi_colors.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/character/presentation/helpers/episode_number.dart';
import 'package:prueba_tecnica_1/feature/character/presentation/providers/character_state.dart';
import 'package:prueba_tecnica_1/feature/character/presentation/widgets/description_widget.dart';
import 'package:prueba_tecnica_1/feature/favorite/presentation/providers/favorite_provider.dart';

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
                        const Icon(Icons.error, color: SciFiColors.error),
                  ),
                ),
              ),
              Positioned(child: BackButton(color: SciFiColors.neonCyan)),
            ],
          ),
          const Divider(thickness: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    character.name,
                    style: TextStyle(
                      color: SciFiColors.neonCyan,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('favorite_button'),
                  onPressed: () {
                    ref
                        .read(favoriteProvider.notifier)
                        .toggleCharacter(character);
                  },
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 30,
                  ),
                  color: SciFiColors.neonCyan,
                ),
              ],
            ),
          ),
          const Divider(thickness: 2),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              character.status,
              style: TextStyle(
                color: SciFiColors.neonCyan,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(thickness: 2),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                DescriptionWidget(
                  icon: Icons.animation_outlined,
                  firstText: 'Especie:',
                  secondText: character.species,
                ),
                SizedBox(height: 12),
                DescriptionWidget(
                  icon: Icons.person_2_rounded,
                  firstText: 'Género:',
                  secondText: character.gender,
                ),
                SizedBox(height: 12),
                DescriptionWidget(
                  icon: Icons.location_on,
                  firstText: 'Origen:',
                  secondText: character.origin.name,
                ),
              ],
            ),
          ),
          const Divider(thickness: 2),
          const Center(
            child: Text(
              'Episodios',
              style: TextStyle(
                color: SciFiColors.neonCyan,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: character.episodes.length,
            itemBuilder: (context, index) {
              final String episode = character.episodes[index];

              return Row(
                children: [
                  const Icon(
                    Icons.movie,
                    size: 25,
                    color: SciFiColors.neonCyan,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Episodio ${episodeNumber(episode)}',
                      style: const TextStyle(
                        fontSize: 24,
                        color: SciFiColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 8),
          ),
        ],
      ),
    );
  }
}
