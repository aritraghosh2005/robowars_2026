import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/auth/models/app_user.dart';
import 'package:robowars_app/features/teams/models/team.dart';
import 'package:robowars_app/services/service_providers.dart';

final _adminUsersProvider = StreamProvider.autoDispose<List<AppUser>>((ref) {
  return ref.watch(userDaoProvider).watchUsers();
});

final _adminTeamsProvider = StreamProvider.autoDispose<List<Team>>((ref) {
  return ref.watch(teamDaoProvider).watchTeams();
});

enum _MemberFilter { all, viewers, participants }

enum _MemberAction { assignTeam, makeTeamAdmin, removeTeamAdmin, makeViewer }

class ParticipantManagerScreen extends ConsumerStatefulWidget {
  const ParticipantManagerScreen({super.key});

  @override
  ConsumerState<ParticipantManagerScreen> createState() =>
      _ParticipantManagerScreenState();
}

class _ParticipantManagerScreenState
    extends ConsumerState<ParticipantManagerScreen> {
  var _filter = _MemberFilter.all;
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(_adminUsersProvider);
    final teamsAsync = ref.watch(_adminTeamsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('PARTICIPANTS & TEAMS')),
      body: switch ((usersAsync, teamsAsync)) {
        (AsyncError(:final error), _) ||
        (_, AsyncError(:final error)) => _ErrorState(message: error.toString()),
        (AsyncData(:final value), AsyncData(value: final teams)) =>
          _buildContent(value, teams),
        _ => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      },
    );
  }

  Widget _buildContent(List<AppUser> users, List<Team> teams) {
    final teamNames = {for (final team in teams) team.id: team.name};
    final normalizedQuery = _query.trim().toLowerCase();
    final visibleUsers = users.where((user) {
      if (user.role == UserRole.admin) return false;
      if (_filter == _MemberFilter.viewers && user.role != UserRole.viewer) {
        return false;
      }
      if (_filter == _MemberFilter.participants &&
          user.role != UserRole.participant) {
        return false;
      }
      if (normalizedQuery.isEmpty) return true;
      return user.displayName.toLowerCase().contains(normalizedQuery) ||
          (user.email?.toLowerCase().contains(normalizedQuery) ?? false);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Search users',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<_MemberFilter>(
                  segments: const [
                    ButtonSegment(value: _MemberFilter.all, label: Text('All')),
                    ButtonSegment(
                      value: _MemberFilter.viewers,
                      label: Text('Viewers'),
                    ),
                    ButtonSegment(
                      value: _MemberFilter.participants,
                      label: Text('Participants'),
                    ),
                  ],
                  selected: {_filter},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) {
                    setState(() => _filter = selection.first);
                  },
                ),
              ),
              if (teams.isEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.45),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Create a team before assigning participants.',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: visibleUsers.isEmpty
              ? const _EmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  itemCount: visibleUsers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final user = visibleUsers[index];
                    return _UserRow(
                      user: user,
                      teamName: user.teamId == null
                          ? null
                          : teamNames[user.teamId],
                      canAssign: teams.isNotEmpty,
                      onAction: (action) =>
                          _handleMemberAction(user, teams, action),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _showAssignmentSheet(AppUser user, List<Team> teams) async {
    if (teams.isEmpty) return;
    final currentTeamExists = teams.any((team) => team.id == user.teamId);
    String selectedTeamId = currentTeamExists ? user.teamId! : teams.first.id;
    var isSaving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.viewInsetsOf(context).bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    user.role == UserRole.viewer
                        ? 'Promote and assign'
                        : 'Assign team',
                    style: const TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user.displayName,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: selectedTeamId,
                    dropdownColor: AppColors.surfaceAlt,
                    decoration: const InputDecoration(
                      labelText: 'Team',
                      prefixIcon: Icon(Icons.groups_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: teams
                        .map(
                          (team) => DropdownMenuItem(
                            value: team.id,
                            child: Text(team.name),
                          ),
                        )
                        .toList(),
                    onChanged: isSaving
                        ? null
                        : (value) {
                            if (value != null) selectedTeamId = value;
                          },
                  ),
                  if (user.role == UserRole.viewer) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'This user will become a participant when assigned.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: isSaving
                        ? null
                        : () async {
                            setSheetState(() => isSaving = true);
                            try {
                              await ref
                                  .read(userDaoProvider)
                                  .assignParticipantToTeam(
                                    user,
                                    selectedTeamId,
                                  );
                              if (!sheetContext.mounted) return;
                              Navigator.pop(sheetContext);
                              if (!mounted) return;
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${user.displayName} assigned successfully.',
                                  ),
                                  backgroundColor: Colors.green.shade700,
                                ),
                              );
                            } catch (error) {
                              if (!sheetContext.mounted) return;
                              setSheetState(() => isSaving = false);
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                SnackBar(
                                  content: Text('Assignment failed: $error'),
                                  backgroundColor: Colors.red.shade700,
                                ),
                              );
                            }
                          },
                    icon: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.person_add_alt_1),
                    label: const Text('Assign to team'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleMemberAction(
    AppUser user,
    List<Team> teams,
    _MemberAction action,
  ) async {
    switch (action) {
      case _MemberAction.assignTeam:
        await _showAssignmentSheet(user, teams);
      case _MemberAction.makeTeamAdmin:
        await _setTeamAdmin(user, true);
      case _MemberAction.removeTeamAdmin:
        await _setTeamAdmin(user, false);
      case _MemberAction.makeViewer:
        await _removeParticipant(user);
    }
  }

  Future<void> _setTeamAdmin(AppUser user, bool isTeamAdmin) async {
    try {
      await ref.read(userDaoProvider).setTeamAdmin(user, isTeamAdmin);
      if (!mounted) return;
      _showMessage(
        isTeamAdmin
            ? '${user.displayName} is now a team admin.'
            : '${user.displayName} is now a regular team member.',
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage('Could not update team role: $error', isError: true);
    }
  }

  Future<void> _removeParticipant(AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove participant?'),
        content: Text(
          '${user.displayName} will become a viewer and lose their team '
          'assignment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(userDaoProvider).removeParticipant(user);
      if (!mounted) return;
      _showMessage('${user.displayName} is now a viewer.');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Could not remove participant: $error', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? Colors.red.shade700
              : Colors.green.shade700,
        ),
      );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.teamName,
    required this.canAssign,
    required this.onAction,
  });

  final AppUser user;
  final String? teamName;
  final bool canAssign;
  final void Function(_MemberAction action) onAction;

  @override
  Widget build(BuildContext context) {
    final isParticipant = user.role == UserRole.participant;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceAlt,
            foregroundImage: user.avatarUrl == null
                ? null
                : NetworkImage(user.avatarUrl!),
            child: user.avatarUrl == null
                ? const Icon(Icons.person_outline, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email ?? 'No email',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Badge(
                      label: isParticipant ? 'PARTICIPANT' : 'VIEWER',
                      color: isParticipant
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                    if (teamName != null)
                      _Badge(label: teamName!, color: Colors.blueAccent),
                    if (user.teamRole == 'Team Admin')
                      const _Badge(label: 'TEAM ADMIN', color: Colors.amber),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<_MemberAction>(
            tooltip: 'Manage user',
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onSelected: onAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _MemberAction.assignTeam,
                enabled: canAssign,
                child: Row(
                  children: [
                    Icon(
                      isParticipant ? Icons.swap_horiz : Icons.person_add_alt_1,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(isParticipant ? 'Change team' : 'Promote and assign'),
                  ],
                ),
              ),
              if (isParticipant && user.teamId != null)
                PopupMenuItem(
                  value: user.teamRole == 'Team Admin'
                      ? _MemberAction.removeTeamAdmin
                      : _MemberAction.makeTeamAdmin,
                  child: Row(
                    children: [
                      const Icon(Icons.admin_panel_settings_outlined, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        user.teamRole == 'Team Admin'
                            ? 'Remove team admin'
                            : 'Make team admin',
                      ),
                    ],
                  ),
                ),
              if (isParticipant)
                const PopupMenuItem(
                  value: _MemberAction.makeViewer,
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_remove_outlined,
                        size: 20,
                        color: Colors.redAccent,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Remove to viewer',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No matching users',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}
