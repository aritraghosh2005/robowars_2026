import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/services/service_providers.dart';

class LeaderboardTab extends ConsumerWidget {
  final VoidCallback onTabClicked;
  const LeaderboardTab({super.key, required this.onTabClicked});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamDao = ref.watch(teamDaoProvider);
    
    return GestureDetector(
      onTap: onTabClicked,
      child: StreamBuilder(
        stream: teamDao.watchTeams(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading leaderboard', style: TextStyle(color: Colors.red)));
          }

          final teams = snapshot.data ?? [];
          
          // Sort teams descending by points
          teams.sort((a, b) => b.pts.compareTo(a.pts));

          if (teams.isEmpty) {
            return const Center(
              child: Text(
                'No teams found',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // List
                ...List.generate(teams.length, (index) {
                  final isTopThree = index < 3;
                  final team = teams[index];
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isTopThree
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isTopThree
                            ? AppColors.primary.withValues(alpha: 0.35)
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
                            team.name,
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
                          '${team.pts} pts',
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
              ],
            ),
          );
        },
      ),
    );
  }
}
