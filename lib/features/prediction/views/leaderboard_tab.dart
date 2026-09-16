import 'package:flutter/material.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/prediction/models/leaderboard_entry.dart';

class LeaderboardTab extends StatefulWidget {
  final VoidCallback onTabClicked;
  const LeaderboardTab({super.key, required this.onTabClicked});

  @override
  State<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<LeaderboardTab> {
  static const List<LeaderboardEntry> _entries = [
    LeaderboardEntry(name: 'Arnav Srivastava', points: 320),
    LeaderboardEntry(name: 'Priya Sharma', points: 280),
    LeaderboardEntry(name: 'Rohan Gupta', points: 250),
    LeaderboardEntry(name: 'Ananya Singh', points: 210),
    LeaderboardEntry(name: 'Vikram Mehta', points: 190),
    LeaderboardEntry(name: 'Deepika Patel', points: 170),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTabClicked,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top 6 list
            ...List.generate(_entries.length, (index) {
              final isTopThree = index < 3;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isTopThree
                      ? AppColors.primary.withOpacity(0.08)
                      : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isTopThree
                        ? AppColors.primary.withOpacity(0.35)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    // Rank circle
                    Container(
                      height: 26,
                      width: 26,
                      decoration: BoxDecoration(
                        color: isTopThree ? AppColors.primary : AppColors.border,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontFamily: 'Space Grotesk',
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _entries[index].name,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${_entries[index].points} pts',
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        color: isTopThree ? AppColors.primary : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: const [
                  Expanded(child: Divider(color: AppColors.border, height: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'YOUR RANK',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        color: AppColors.textMuted,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.border, height: 1)),
                ],
              ),
            ),

            // Current user rank
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    height: 26,
                    width: 26,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '10',
                        style: TextStyle(
                          fontFamily: 'Space Grotesk',
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'You (Aritra Ghosh)',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Text(
                    '-50 pts',
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
