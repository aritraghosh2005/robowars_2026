import 'package:flutter/material.dart';
import 'package:robowars_app/core/theme/app_theme.dart';

class TeamChoiceWidget extends StatelessWidget {
  final String teamName;
  final bool isExpanded;

  const TeamChoiceWidget({
    super.key,
    required this.teamName,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 54,
      width: 110,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isExpanded ? AppColors.primary.withOpacity(0.15) : AppColors.surfaceAlt,
        border: Border.all(
          color: isExpanded ? AppColors.primary : AppColors.border,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          teamName,
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            color: isExpanded ? AppColors.primary : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
