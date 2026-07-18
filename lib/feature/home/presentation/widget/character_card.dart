import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/helpers/status_color.dart';

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
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              onTap: () => context.push('/character', extra: character.id),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(tokens.radius.medium),
                ),
                child: Hero(
                  tag: character.id,
                  child: AppNetworkImage(
                    url: character.image,
                    widthImage: double.infinity,
                    heightImage: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: Icon(AppIcons.error, color: colors.error),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(tokens.spacing.xSmall),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.h6(
                        character.name,
                        maxLines: 2,
                        fontWeight: FontWeight.bold,
                      ),
                      AppText.label(
                        character.status,
                        color: statusColor(character.status, colors),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: Key('favorite_button_${character.id}'),
                  onPressed: onPressed,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.spacing.xSmall),
        ],
      ),
    );
  }
}
