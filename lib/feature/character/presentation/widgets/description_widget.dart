import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

class DescriptionWidget extends StatelessWidget {
  final IconData icon;
  final String firstText;
  final String secondText;
  const DescriptionWidget({
    super.key,
    required this.icon,
    required this.firstText,
    required this.secondText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 25, color: colors.primary),
            SizedBox(width: tokens.spacing.small),
            AppText.h6(
              firstText,
              color: colors.primary,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
        SizedBox(width: tokens.spacing.smallMedium),
        Expanded(
          child: AppText.bodyLg(
            secondText,
            color: colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
