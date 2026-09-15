import 'package:flutter/material.dart';
import 'package:robowars_app/theme/app_theme.dart';

class QuickStats extends StatelessWidget {
  final Map<String, String> stats;

  const QuickStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final entries = stats.entries.toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          // Grid of stats — 2x2
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.0,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final isTop = index < 2;
              final isLeft = index % 2 == 0;
              final isTopLeft = index == 0;
              final isTopRight = index == 1;
              final isBottomLeft = index == entries.length - 2;
              final isBottomRight = index == entries.length - 1;

              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: isLeft ? const BorderSide(color: AppColors.border, width: 1) : BorderSide.none,
                    bottom: isTop ? const BorderSide(color: AppColors.border, width: 1) : BorderSide.none,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: isTopLeft ? const Radius.circular(15) : Radius.zero,
                    topRight: isTopRight ? const Radius.circular(15) : Radius.zero,
                    bottomLeft: isBottomLeft ? const Radius.circular(15) : Radius.zero,
                    bottomRight: isBottomRight ? const Radius.circular(15) : Radius.zero,
                  ),
                ),
                child: Stack(
                  children: [
                    // Subtle gradient glow in corner
                    Positioned(
                      top: 0,
                      left: isLeft ? 0 : null,
                      right: isLeft ? null : 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.12),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            entry.value,
                            style: const TextStyle(
                              fontFamily: 'Space Grotesk',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            entry.key.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
