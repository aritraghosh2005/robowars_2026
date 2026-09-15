import 'package:flutter/material.dart';
import 'package:robowars_app/theme/app_theme.dart';

class VSIndicator extends StatelessWidget {
  const VSIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'VS',
        style: TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
