import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/schedule/models/match.dart';
import 'package:robowars_app/features/schedule/viewmodels/schedule_viewmodel.dart';
import 'package:robowars_app/shared/widgets/cyber_sliver_app_bar.dart';
import 'package:robowars_app/shared/widgets/weight_filter_chips.dart';
import 'package:robowars_app/shared/widgets/tab_loading_wrapper.dart';
import 'package:robowars_app/features/prediction/views/prediction_popup.dart';
import 'package:robowars_app/features/notifications/views/notification_drawer.dart';

class Schedule extends ConsumerWidget {
  const Schedule({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleViewModelProvider);
    final vm = ref.read(scheduleViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      endDrawer: const NotificationDrawer(),
      body: TabLoadingWrapper(
        headerSlivers: [
          CyberSliverAppBar(
            title: 'SCHEDULE',
            onMenuTap: () => Scaffold.of(context).openDrawer(),
          ),
        ],
        contentSlivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                children: [
                  _buildTabBar(state.selectedTab, vm),
                  const SizedBox(height: 16),
                  WeightFilterChips(
                    categories: const ['All', '8kg', '15kg', '60kg'],
                    selectedCategory: state.selectedWeightCategory,
                    onSelected: (category) => vm.setWeightCategory(category),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            sliver: state.matches.when(
              data: (_) {
                final filteredMatches = vm.filteredMatches;
                if (filteredMatches.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Text('No matches scheduled for this category.', style: TextStyle(color: Colors.white)),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildMatchCard(filteredMatches[index], state.selectedTab),
                    childCount: filteredMatches.length,
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (e, st) => SliverToBoxAdapter(
                child: Center(
                  child: Text('Error loading matches: $e', style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(String selectedTab, ScheduleViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: ['Upcoming', 'Completed'].map((tab) {
          final isSelected = selectedTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => vm.setTab(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(
                    tab,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textMuted,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMatchCard(Match match, String selectedTab) {
    final isUpcoming = selectedTab == 'Upcoming';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          // Top bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    match.category,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                if (isUpcoming)
                  Text(
                    match.time,
                    style: const TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )
                else
                  Row(
                    children: [
                      const Text(
                        'WINNER  ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        match.winner,
                        style: const TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Match content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Team 1
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.team1,
                        style: const TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        match.bot1,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // VS
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'VS',
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                // Team 2
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        match.team2,
                        style: const TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        match.bot2,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          if (isUpcoming) ...[
            const Divider(color: AppColors.border, height: 1),
            Consumer(
              builder: (context, ref, child) {
                return InkWell(
                  onTap: () {
                    // Show prediction popup
                    showDialog(
                      context: context,
                      barrierColor: Colors.black87,
                      builder: (context) => PredictionPopup(match: match),
                    );
                  },
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.online_prediction, color: AppColors.primary, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'PREDICT WINNER',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 1.2,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
