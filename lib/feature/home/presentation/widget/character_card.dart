import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prueba_tecnica_1/core/tokens/scifi_colors.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';

class CharacterCard extends StatelessWidget {
  final bool isFavorite;
  final Character character;
  final void Function()? onPressed;

  const CharacterCard({
    super.key,
    required this.character,
    required this.isFavorite,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SciFiColors.deepBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SciFiColors.success),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                context.go('/character', extra: character.id);
              },
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Hero(
                  tag: character.id,
                  child: CachedNetworkImage(
                    imageUrl: character.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (_, __) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.error, color: SciFiColors.error),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        character.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: SciFiColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        character.status,
                        style: const TextStyle(color: SciFiColors.neonCyan),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: Key('favorite_button_${character.id}'),
                  onPressed: onPressed,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: SciFiColors.success,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
