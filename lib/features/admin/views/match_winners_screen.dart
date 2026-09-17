import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/admin/viewmodels/match_editor_viewmodel.dart';
import 'package:robowars_app/features/schedule/models/match.dart';

class MatchWinnersScreen extends ConsumerWidget {
  const MatchWinnersScreen({super.key});

  void _showWinnerSelector(BuildContext context, WidgetRef ref, Match match) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'SET MATCH WINNER',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Space Grotesk',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${match.category.toUpperCase()}  •  ${match.time}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 20),

              // Team 1 Option
              _buildWinnerOption(
                context: context,
                teamName: match.team1,
                isSelected: match.winner == match.team1,
                onTap: () => _saveWinner(context, ref, match, match.team1),
              ),
              const SizedBox(height: 10),

              // Team 2 Option
              _buildWinnerOption(
                context: context,
                teamName: match.team2,
                isSelected: match.winner == match.team2,
                onTap: () => _saveWinner(context, ref, match, match.team2),
              ),
              const SizedBox(height: 16),

              // Clear winner option
              OutlinedButton.icon(
                onPressed: () => _saveWinner(context, ref, match, ''),
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.textMuted, size: 18),
                label: const Text(
                  'CLEAR WINNER (UNDECIDED)',
                  style: TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    letterSpacing: 1.0,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWinnerOption({
    required BuildContext context,
    required String teamName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.amber.withValues(alpha: 0.15) : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? Colors.amber : AppColors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.amber.withValues(alpha: 0.2)
                      : AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: isSelected ? Colors.amber : AppColors.textMuted,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  teamName.isEmpty ? 'Unknown Team' : teamName,
                  style: TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isSelected ? Colors.amber : Colors.white,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.amber, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveWinner(BuildContext context, WidgetRef ref, Match match, String winnerName) async {
    Navigator.pop(context);
    final updatedMatch = match.copyWith(winner: winnerName);
    await ref.read(matchEditorViewModelProvider.notifier).saveMatch(updatedMatch);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(winnerName.isEmpty ? 'Winner cleared' : 'Winner declared: $winnerName'),
          backgroundColor: AppColors.surfaceAlt,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchEditorViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'SET MATCH WINNERS',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Space Grotesk',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: state.isLoading && state.matches.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                if (state.errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                    ),
                    child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ),
                Expanded(
                  child: state.matches.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Icon(
                                  Icons.emoji_events_outlined,
                                  color: AppColors.textMuted,
                                  size: 44,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No matches found',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Space Grotesk',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Create matches first in "Manage Matches"',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: state.matches.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final match = state.matches[index];
                            final hasWinner = match.winner.isNotEmpty;

                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: hasWinner ? Colors.amber.withValues(alpha: 0.4) : AppColors.border,
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                                        ),
                                        child: Text(
                                          match.category.toUpperCase(),
                                          style: const TextStyle(
                                            fontFamily: 'Space Grotesk',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.schedule, size: 13, color: AppColors.textMuted),
                                      const SizedBox(width: 4),
                                      Text(
                                        match.time.isEmpty ? 'TBD' : match.time,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (hasWinner)
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.emoji_events, color: Colors.amber, size: 13),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    match.winner,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontFamily: 'Space Grotesk',
                                                      color: Colors.amber,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceAlt,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: AppColors.border),
                                          ),
                                          child: const Text(
                                            'PENDING',
                                            style: TextStyle(
                                              fontFamily: 'Space Grotesk',
                                              color: AppColors.textMuted,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),

                                  // Teams Display
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          match.team1,
                                          style: TextStyle(
                                            fontFamily: 'Space Grotesk',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: match.winner == match.team1 ? Colors.amber : Colors.white,
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(
                                          'VS',
                                          style: TextStyle(
                                            fontFamily: 'Space Grotesk',
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          match.team2,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontFamily: 'Space Grotesk',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: match.winner == match.team2 ? Colors.amber : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Select Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _showWinnerSelector(context, ref, match),
                                      icon: const Icon(Icons.emoji_events_outlined, size: 18),
                                      label: Text(
                                        hasWinner ? 'CHANGE WINNER' : 'SELECT WINNER',
                                        style: const TextStyle(
                                          fontFamily: 'Space Grotesk',
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                          fontSize: 13,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: hasWinner
                                            ? Colors.amber.withValues(alpha: 0.2)
                                            : AppColors.primary.withValues(alpha: 0.15),
                                        foregroundColor: hasWinner ? Colors.amber : AppColors.primary,
                                        elevation: 0,
                                        side: BorderSide(
                                          color: hasWinner
                                              ? Colors.amber.withValues(alpha: 0.5)
                                              : AppColors.primary.withValues(alpha: 0.5),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
