import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/admin/viewmodels/match_editor_viewmodel.dart';
import 'package:robowars_app/features/admin/viewmodels/team_editor_viewmodel.dart';
import 'package:robowars_app/features/schedule/models/match.dart';

class MatchEditorScreen extends ConsumerWidget {
  const MatchEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchEditorViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'MANAGE MATCHES',
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
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
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
                                  Icons.sports_esports_outlined,
                                  color: AppColors.textMuted,
                                  size: 44,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No matches scheduled yet',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Space Grotesk',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Tap "+" to schedule the first arena fight',
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
                                  color: hasWinner
                                      ? Colors.amber.withValues(alpha: 0.3)
                                      : AppColors.border,
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
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                                        onPressed: () => _openEditorDialog(context, ref, match),
                                      ),
                                    ],
                                  ),
                                  if (hasWinner) ...[
                                    const SizedBox(height: 10),
                                    Container(
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
                                              'WINNER: ${match.winner}',
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
                                  ],
                                  const SizedBox(height: 14),
                                  // Teams Versus Row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          match.team1.isEmpty ? 'Team 1' : match.team1,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Space Grotesk',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: match.winner == match.team1 ? Colors.amber : Colors.white,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 6),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceAlt,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: const Text(
                                          'VS',
                                          style: TextStyle(
                                            fontFamily: 'Space Grotesk',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          match.team2.isEmpty ? 'Team 2' : match.team2,
                                          textAlign: TextAlign.end,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Space Grotesk',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: match.winner == match.team2 ? Colors.amber : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _openEditorDialog(context, ref, null),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'NEW MATCH',
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _openEditorDialog(BuildContext context, WidgetRef ref, Match? match) {
    ref.read(matchEditorViewModelProvider.notifier).selectMatch(match);
    showDialog(
      context: context,
      builder: (context) => const _MatchEditorDialog(),
    );
  }
}

class _MatchEditorDialog extends ConsumerStatefulWidget {
  const _MatchEditorDialog();

  @override
  ConsumerState<_MatchEditorDialog> createState() => _MatchEditorDialogState();
}

class _MatchEditorDialogState extends ConsumerState<_MatchEditorDialog> {
  String _selectedTeam1Id = '';
  String _selectedTeam2Id = '';
  late TextEditingController _categoryCtrl;
  late TextEditingController _timeCtrl;

  @override
  void initState() {
    super.initState();
    final selectedMatch = ref.read(matchEditorViewModelProvider).selectedMatch;
    _selectedTeam1Id = selectedMatch?.team1 ?? '';
    _selectedTeam2Id = selectedMatch?.team2 ?? '';
    _categoryCtrl = TextEditingController(text: selectedMatch?.category ?? '15kg');
    _timeCtrl = TextEditingController(text: selectedMatch?.time ?? '');

    // Ensure teams are loaded
    ref.read(teamEditorViewModelProvider);
  }

  @override
  void dispose() {
    _categoryCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  void _showTeamSelector(BuildContext context, bool isTeam1) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final teamState = ref.watch(teamEditorViewModelProvider);

            if (teamState.isLoading && teamState.teams.isEmpty) {
              return const SizedBox(
                height: 240,
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              );
            }

            if (teamState.teams.isEmpty) {
              return const SizedBox(
                height: 240,
                child: Center(
                  child: Text(
                    'No teams registered. Add teams first.',
                    style: TextStyle(color: Colors.white70, fontFamily: 'Space Grotesk'),
                  ),
                ),
              );
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.85,
              minChildSize: 0.4,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          isTeam1 ? 'SELECT TEAM 1' : 'SELECT TEAM 2',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Space Grotesk',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: teamState.teams.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final team = teamState.teams[index];
                            final isAlreadySelectedOtherSide = isTeam1
                                ? team.name == _selectedTeam2Id
                                : team.name == _selectedTeam1Id;

                            final isCurrent = isTeam1
                                ? team.name == _selectedTeam1Id
                                : team.name == _selectedTeam2Id;

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: isAlreadySelectedOtherSide
                                    ? null
                                    : () {
                                        setState(() {
                                          if (isTeam1) {
                                            _selectedTeam1Id = team.name;
                                          } else {
                                            _selectedTeam2Id = team.name;
                                          }
                                        });
                                        Navigator.pop(context);
                                      },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? AppColors.primary.withValues(alpha: 0.15)
                                        : AppColors.surfaceAlt,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isCurrent ? AppColors.primary : AppColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.precision_manufacturing, color: AppColors.primary, size: 20),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              team.name,
                                              style: TextStyle(
                                                color: isAlreadySelectedOtherSide ? AppColors.textMuted : Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Space Grotesk',
                                                fontSize: 15,
                                                decoration: isAlreadySelectedOtherSide ? TextDecoration.lineThrough : null,
                                              ),
                                            ),
                                            Text(
                                              '${team.bots.length} Bots  •  ${team.pts} Pts',
                                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isCurrent)
                                        const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchEditorViewModelProvider);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                state.selectedMatch == null ? 'SCHEDULE MATCH' : 'EDIT MATCH',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Team 1 selector button
              OutlinedButton(
                onPressed: () => _showTeamSelector(context, true),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _selectedTeam1Id.isNotEmpty ? AppColors.primary : AppColors.border,
                  ),
                  backgroundColor: AppColors.surfaceAlt,
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sports_esports, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedTeam1Id.isEmpty ? 'Select Team 1' : _selectedTeam1Id,
                        style: TextStyle(
                          color: _selectedTeam1Id.isEmpty ? AppColors.textMuted : Colors.white,
                          fontFamily: 'Space Grotesk',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'VS',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Team 2 selector button
              OutlinedButton(
                onPressed: () => _showTeamSelector(context, false),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _selectedTeam2Id.isNotEmpty ? AppColors.primary : AppColors.border,
                  ),
                  backgroundColor: AppColors.surfaceAlt,
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sports_esports, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedTeam2Id.isEmpty ? 'Select Team 2' : _selectedTeam2Id,
                        style: TextStyle(
                          color: _selectedTeam2Id.isEmpty ? AppColors.textMuted : Colors.white,
                          fontFamily: 'Space Grotesk',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Category Field
              TextField(
                controller: _categoryCtrl,
                style: const TextStyle(color: Colors.white, fontFamily: 'Space Grotesk'),
                decoration: InputDecoration(
                  labelText: 'Weight Category',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceAlt,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Time Field
              TextField(
                controller: _timeCtrl,
                style: const TextStyle(color: Colors.white, fontFamily: 'Space Grotesk'),
                decoration: InputDecoration(
                  labelText: 'Match Time (e.g. 10:30 AM)',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceAlt,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: state.isSaving
                        ? null
                        : () async {
                            final newMatch = Match(
                              id: state.selectedMatch?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                              team1: _selectedTeam1Id,
                              team2: _selectedTeam2Id,
                              bot1: state.selectedMatch?.bot1 ?? '',
                              bot2: state.selectedMatch?.bot2 ?? '',
                              category: _categoryCtrl.text.trim(),
                              time: _timeCtrl.text.trim(),
                              winner: state.selectedMatch?.winner ?? '',
                            );
                            await ref.read(matchEditorViewModelProvider.notifier).saveMatch(newMatch);
                            if (context.mounted) Navigator.pop(context);
                          },
                    child: state.isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'SAVE MATCH',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Space Grotesk',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
