import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/core/tokens/scifi_colors.dart';
import 'package:prueba_tecnica_1/feature/favorite/presentation/providers/favorite_provider.dart';

class FavoritePage extends ConsumerWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characters = ref.watch(favoriteProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Favoritos',
          style: TextStyle(
            color: SciFiColors.neonCyan,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        leading: const BackButton(color: SciFiColors.neonCyan),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: characters.length,
        separatorBuilder: (_, __) => const SizedBox(height: 15),
        itemBuilder: (context, index) {
          final character = characters[index];

          final isFavorite = ref.watch(
            favoriteProvider.select(
              (list) => list.any((c) => c.id == character.id),
            ),
          );

          return Stack(
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: SciFiColors.deepBlue,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SciFiColors.success),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(16),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: character.image,
                        width: 120,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              character.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: SciFiColors.neonCyan,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              character.species,
                              style: const TextStyle(
                                color: SciFiColors.neonCyan,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              character.status,
                              style: const TextStyle(
                                color: SciFiColors.neonCyan,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 50,
                right: 8,
                child: IconButton(
                  key: ValueKey('favorite_button_${character.id}'),
                  onPressed: () {
                    ref
                        .read(favoriteProvider.notifier)
                        .toggleCharacter(character);
                  },
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: SciFiColors.neonCyan,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
