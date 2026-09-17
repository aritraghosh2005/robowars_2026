import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/admin/viewmodels/match_editor_viewmodel.dart';
import 'package:robowars_app/features/admin/viewmodels/team_editor_viewmodel.dart';
import 'package:robowars_app/features/schedule/models/match.dart';

class MatchWinnersScreen extends ConsumerWidget {
  const MatchWinnersScreen({super.key});

  Future<void> _showWinnerSelector(
    BuildContext context,
    WidgetRef ref,
    Match match,
  ) {
    final teamState = ref.read(teamEditorViewModelProvider);
    String resolveTeamId(String name, String storedId) {
      if (storedId.isNotEmpty) return storedId;
      for (final team in teamState.teams) {
        if (team.name == name) return team.id;
      }
      return '';
    }

    final team1Id = resolveTeamId(match.team1, match.team1Id);
    final team2Id = resolveTeamId(match.team2, match.team2Id);

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) => _WinnerSelectorBottomSheet(
        match: match,
        team1Id: team1Id,
        team2Id: team2Id,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchEditorViewModelProvider);
    final teamState = ref.watch(teamEditorViewModelProvider);

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
                                        match.displayTime,
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
                                  if (hasWinner) ...[
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${match.team1Points} PTS',
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${match.team2Points} PTS',
                                            textAlign: TextAlign.end,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 16),

                                  // Select Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: teamState.isLoading
                                          ? null
                                          : () => _showWinnerSelector(
                                              context,
                                              ref,
                                              match,
                                            ),
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

class _WinnerSelectorBottomSheet extends ConsumerStatefulWidget {
  final Match match;
  final String team1Id;
  final String team2Id;

  const _WinnerSelectorBottomSheet({
    required this.match,
    required this.team1Id,
    required this.team2Id,
  });

  @override
  ConsumerState<_WinnerSelectorBottomSheet> createState() =>
      _WinnerSelectorBottomSheetState();
}

class _WinnerSelectorBottomSheetState
    extends ConsumerState<_WinnerSelectorBottomSheet> {
  late final TextEditingController _team1PointsController;
  late final TextEditingController _team2PointsController;
  late String _selectedWinnerId;

  @override
  void initState() {
    super.initState();
    _selectedWinnerId = widget.match.winnerId;
    if (_selectedWinnerId.isEmpty && widget.match.winner == widget.match.team1) {
      _selectedWinnerId = widget.team1Id;
    } else if (_selectedWinnerId.isEmpty &&
        widget.match.winner == widget.match.team2) {
      _selectedWinnerId = widget.team2Id;
    }
    _team1PointsController = TextEditingController(
      text: widget.match.team1Points.toString(),
    );
    _team2PointsController = TextEditingController(
      text: widget.match.team2Points.toString(),
    );
  }

  @override
  void dispose() {
    _team1PointsController.dispose();
    _team2PointsController.dispose();
    super.dispose();
  }

  Future<void> _saveResult() async {
    final team1Points = int.tryParse(_team1PointsController.text);
    final team2Points = int.tryParse(_team2PointsController.text);
    if (widget.team1Id.isEmpty || widget.team2Id.isEmpty) {
      _showError('Team IDs are missing. Re-save this match first.');
      return;
    }
    if (_selectedWinnerId.isEmpty) {
      _showError('Select the winning team.');
      return;
    }
    if (team1Points == null || team2Points == null) {
      _showError('Enter points for both teams.');
      return;
    }

    final winnerName = _selectedWinnerId == widget.team1Id
        ? widget.match.team1
        : widget.match.team2;
    final updatedMatch = widget.match.copyWith(
      team1Id: widget.team1Id,
      team2Id: widget.team2Id,
      winner: winnerName,
      winnerId: _selectedWinnerId,
      team1Points: team1Points,
      team2Points: team2Points,
      status: 'completed',
    );
    final saved = await ref
        .read(matchEditorViewModelProvider.notifier)
        .saveMatchResult(updatedMatch);
    if (!mounted) return;
    if (!saved) {
      _showError('Could not save the match result.');
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$winnerName won • ${widget.match.team1}: $team1Points • ${widget.match.team2}: $team2Points',
        ),
        backgroundColor: AppColors.surfaceAlt,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _clearResult() async {
    final cleared = widget.match.copyWith(
      team1Id: widget.team1Id,
      team2Id: widget.team2Id,
      winner: '',
      winnerId: '',
      team1Points: 0,
      team2Points: 0,
      status: 'scheduled',
    );
    final saved = await ref
        .read(matchEditorViewModelProvider.notifier)
        .saveMatchResult(cleared);
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Result cleared and team totals reversed.'),
        ),
      );
    } else {
      _showError('Could not clear the result.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  Widget _pointsField({
    required TextEditingController controller,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Space Grotesk',
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            labelText: 'Points',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildWinnerOption({
    required String teamName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.amber.withValues(alpha: 0.15)
                : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.amber : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: isSelected ? Colors.amber : AppColors.textMuted,
                size: 22,
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

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
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
            'MATCH RESULT',
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
            '${match.category.toUpperCase()}  •  ${match.displayTime}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          _buildWinnerOption(
            teamName: match.team1,
            isSelected: _selectedWinnerId == widget.team1Id,
            onTap: () => setState(() => _selectedWinnerId = widget.team1Id),
          ),
          const SizedBox(height: 10),
          _buildWinnerOption(
            teamName: match.team2,
            isSelected: _selectedWinnerId == widget.team2Id,
            onTap: () => setState(() => _selectedWinnerId = widget.team2Id),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _pointsField(
                  controller: _team1PointsController,
                  label: match.team1,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _pointsField(
                  controller: _team2PointsController,
                  label: match.team2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveResult,
              icon: const Icon(Icons.save_outlined),
              label: const Text('SAVE RESULT'),
            ),
          ),
          const SizedBox(height: 8),
          if (match.pointsApplied || match.winner.isNotEmpty)
            TextButton.icon(
              onPressed: _clearResult,
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('Clear result and reverse points'),
            ),
        ],
      ),
    );
  }
}
