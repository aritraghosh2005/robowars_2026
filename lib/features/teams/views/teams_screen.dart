import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/teams/models/team.dart';
import 'package:robowars_app/features/teams/viewmodels/teams_viewmodel.dart';
import 'package:robowars_app/features/teams/views/widgets/team_detail_popup.dart';
import 'package:robowars_app/shared/widgets/weight_filter_chips.dart';
import 'package:robowars_app/shared/widgets/secondary_app_bar.dart';

class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teamsViewModelProvider);
    final vm = ref.read(teamsViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SecondarySliverAppBar(
            title: state.isTeamsSelected ? 'TEAMS' : 'LEADERBOARD',
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                children: [
                  _buildToggle(state.isTeamsSelected, vm),
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
            sliver: state.teams.when(
              data: (_) {
                final filteredTeams = vm.filteredTeams;
                if (filteredTeams.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Text('No teams found for this category.', style: TextStyle(color: Colors.white)),
                    ),
                  );
                }
                return state.isTeamsSelected
                    ? _buildTeamsList(context, filteredTeams)
                    : _buildTableView(filteredTeams);
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (e, st) => SliverToBoxAdapter(
                child: Center(
                  child: Text('Error loading teams: $e', style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(bool isTeamsSelected, TeamsViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _toggleButton('Teams', true, isTeamsSelected, vm),
          _toggleButton('Leaderboard', false, isTeamsSelected, vm),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool forTeams, bool isTeamsSelected, TeamsViewModel vm) {
    final isSelected = isTeamsSelected == forTeams;
    return Expanded(
      child: GestureDetector(
        onTap: () => vm.toggleView(forTeams),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  SliverList _buildTeamsList(BuildContext context, List<Team> teams) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final team = teams[index];
          return GestureDetector(
            onTap: () => TeamDetailPopup.show(context, team),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Row(
                children: [
                  // Red left accent stripe
                  Container(
                    width: 4,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Team logo placeholder
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.smart_toy_outlined, color: AppColors.textMuted, size: 24),
                  ),
                  const SizedBox(width: 16),
                  // Team info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          style: const TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: team.bots.map<Widget>((bot) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                              ),
                              child: Text(
                                '${bot.name} · ${bot.weight}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          );
        },
        childCount: teams.length,
      ),
    );
  }

  SliverList _buildTableView(List<Team> teams) {
    final sorted = [...teams]..sort((a, b) => b.pts.compareTo(a.pts));
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final team = sorted[index];
          final isTopThree = index < 3;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isTopThree ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isTopThree ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isTopThree ? AppColors.primary : AppColors.textMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      team.name,
                      style: const TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  _statCol('M', '${team.wins + team.losses}'),
                  const SizedBox(width: 16),
                  _statCol('W', '${team.wins}'),
                  const SizedBox(width: 16),
                  _statCol('L', '${team.losses}'),
                  const SizedBox(width: 16),
                  _statColHighlight('PTS', '${team.pts}'),
                ],
              ),
            ),
          );
        },
        childCount: sorted.length,
      ),
    );
  }

  Widget _statCol(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 9, color: AppColors.textMuted, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _statColHighlight(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 9, color: AppColors.primary, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
      ],
    );
  }
}
