import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/admin/viewmodels/team_editor_viewmodel.dart';
import 'package:robowars_app/features/teams/models/bot.dart';
import 'package:robowars_app/features/teams/models/team.dart';

class TeamEditorScreen extends ConsumerWidget {
  const TeamEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teamEditorViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'MANAGE TEAMS',
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
      body: state.isLoading && state.teams.isEmpty
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
                  child: state.teams.isEmpty
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
                                  Icons.groups_outlined,
                                  color: AppColors.textMuted,
                                  size: 44,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No teams registered yet',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Space Grotesk',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Tap "+" to register a team and its bots',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: state.teams.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final team = state.teams[index];

                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                        ),
                                        child: const Icon(Icons.precision_manufacturing, color: AppColors.primary, size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              team.name,
                                              style: const TextStyle(
                                                fontFamily: 'Space Grotesk',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                            if (team.description.isNotEmpty)
                                              Text(
                                                team.description,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                                        ),
                                        child: Text(
                                          '${team.pts} PTS',
                                          style: const TextStyle(
                                            fontFamily: 'Space Grotesk',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                                        onPressed: () => _openEditorDialog(context, ref, team),
                                      ),
                                    ],
                                  ),
                                  if (team.bots.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: team.bots.map((bot) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceAlt,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: AppColors.border),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.smart_toy_outlined, color: AppColors.textSecondary, size: 13),
                                              const SizedBox(width: 5),
                                              Text(
                                                bot.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '(${bot.weight})',
                                                style: const TextStyle(
                                                  color: AppColors.textMuted,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
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
          'NEW TEAM',
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

  void _openEditorDialog(BuildContext context, WidgetRef ref, Team? team) {
    ref.read(teamEditorViewModelProvider.notifier).selectTeam(team);
    showDialog(
      context: context,
      builder: (context) => const _TeamEditorDialog(),
    );
  }
}

class BotFormController {
  final TextEditingController nameCtrl;
  final TextEditingController weightCtrl;

  BotFormController({String name = '', String weight = '15kg'})
      : nameCtrl = TextEditingController(text: name),
        weightCtrl = TextEditingController(text: weight);

  void dispose() {
    nameCtrl.dispose();
    weightCtrl.dispose();
  }
}

class _TeamEditorDialog extends ConsumerStatefulWidget {
  const _TeamEditorDialog();

  @override
  ConsumerState<_TeamEditorDialog> createState() => _TeamEditorDialogState();
}

class _TeamEditorDialogState extends ConsumerState<_TeamEditorDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  final List<BotFormController> _botControllers = [];

  @override
  void initState() {
    super.initState();
    final selectedTeam = ref.read(teamEditorViewModelProvider).selectedTeam;
    _nameCtrl = TextEditingController(text: selectedTeam?.name ?? '');
    _descCtrl = TextEditingController(text: selectedTeam?.description ?? '');

    if (selectedTeam != null && selectedTeam.bots.isNotEmpty) {
      for (var bot in selectedTeam.bots) {
        _botControllers.add(BotFormController(name: bot.name, weight: bot.weight));
      }
    } else {
      _botControllers.add(BotFormController());
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    for (var ctrl in _botControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _addBot() {
    setState(() {
      _botControllers.add(BotFormController());
    });
  }

  void _removeBot(int index) {
    if (_botControllers.length > 1) {
      setState(() {
        final ctrl = _botControllers.removeAt(index);
        ctrl.dispose();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A team must have at least one bot.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamEditorViewModelProvider);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.selectedTeam == null ? 'REGISTER TEAM' : 'EDIT TEAM',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _nameCtrl,
                  style: const TextStyle(color: Colors.white, fontFamily: 'Space Grotesk'),
                  decoration: InputDecoration(
                    labelText: 'Team Name',
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
                const SizedBox(height: 12),

                TextField(
                  controller: _descCtrl,
                  style: const TextStyle(color: Colors.white, fontFamily: 'Space Grotesk'),
                  decoration: InputDecoration(
                    labelText: 'Description / Bio',
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
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'BOTS IN ROSTER',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontFamily: 'Space Grotesk',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 12,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addBot,
                      icon: const Icon(Icons.add, color: AppColors.primary, size: 16),
                      label: const Text(
                        'ADD BOT',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontFamily: 'Space Grotesk',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                ...List.generate(_botControllers.length, (index) {
                  final botCtrl = _botControllers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              TextField(
                                controller: botCtrl.nameCtrl,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                decoration: const InputDecoration(
                                  labelText: 'Bot Name',
                                  labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
                                  isDense: true,
                                  border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: botCtrl.weightCtrl,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                decoration: const InputDecoration(
                                  labelText: 'Category / Weight (e.g. 15kg)',
                                  labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
                                  isDense: true,
                                  border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _removeBot(index),
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (state.selectedTeam != null)
                      TextButton(
                        onPressed: state.isSaving
                            ? null
                            : () async {
                                await ref.read(teamEditorViewModelProvider.notifier).deleteTeam(state.selectedTeam!.id);
                                if (context.mounted) Navigator.pop(context);
                              },
                        child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                      ),
                    const Spacer(),
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
                              final bots = _botControllers
                                  .map((c) => Bot(name: c.nameCtrl.text.trim(), weight: c.weightCtrl.text.trim()))
                                  .where((b) => b.name.isNotEmpty)
                                  .toList();

                              final newTeam = Team(
                                id: state.selectedTeam?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                name: _nameCtrl.text.trim(),
                                bots: bots,
                                description: _descCtrl.text.trim(),
                                wins: state.selectedTeam?.wins ?? 0,
                                losses: state.selectedTeam?.losses ?? 0,
                                pts: state.selectedTeam?.pts ?? 0,
                              );
                              await ref.read(teamEditorViewModelProvider.notifier).saveTeam(newTeam);
                              if (context.mounted) Navigator.pop(context);
                            },
                      child: state.isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'SAVE TEAM',
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
      ),
    );
  }
}
