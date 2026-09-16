import 'package:flutter/material.dart';
import 'package:robowars_app/core/theme/app_theme.dart';

/// A reusable section label widget used across home screen sections.
/// Displays a red vertical accent bar followed by an uppercase label.
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }
}
