import 'package:flutter/material.dart';
import 'package:prueba_tecnica_1/core/tokens/scifi_colors.dart';

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 25, color: SciFiColors.neonCyan),
            SizedBox(width: 12),
            Text(
              firstText,
              style: TextStyle(
                color: SciFiColors.neonCyan,
                fontSize: 25,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        SizedBox(width: 20),
        Expanded(
          child: Text(
            secondText,
            style: TextStyle(
              fontSize: 25,
              color: SciFiColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
