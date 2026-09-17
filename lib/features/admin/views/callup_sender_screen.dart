import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/admin/viewmodels/callup_sender_viewmodel.dart';
import 'package:robowars_app/features/teams/models/team.dart';
import 'package:robowars_app/services/service_providers.dart';
import 'package:robowars_app/features/admin/auth/admin_service.dart';
import 'package:robowars_app/features/auth/models/app_user.dart';
import 'package:url_launcher/url_launcher.dart';

class CallupSenderScreen extends ConsumerStatefulWidget {
  const CallupSenderScreen({super.key});

  @override
  ConsumerState<CallupSenderScreen> createState() => _CallupSenderScreenState();
}

class _CallupSenderScreenState extends ConsumerState<CallupSenderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController(
    text: 'Please report to the arena pit area immediately.',
  );
  String? _selectedTeamId;
  List<Team> _latestTeams = const [];

  Team? get _selectedTeam {
    final selectedId = _selectedTeamId;
    if (selectedId == null) return null;
    return _latestTeams.where((team) => team.id == selectedId).firstOrNull;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final selectedTeam = _selectedTeam;
    if (_formKey.currentState!.validate() && selectedTeam != null) {
      final success = await ref
          .read(callupSenderViewModelProvider.notifier)
          .sendCallup(
            selectedTeam.id,
            selectedTeam.name,
            _messageController.text.trim(),
          );

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Urgent call-up queued for ${selectedTeam.name}.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      } else {
        final error = ref.read(callupSenderViewModelProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else if (selectedTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a team to call up.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleState = ref.watch(roleServiceProvider).asData?.value;
    if (roleState == null || roleState.service is! AdminService) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text(
            'Permission denied: Not an admin',
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    }

    final state = ref.watch(callupSenderViewModelProvider);
    final teamsStream = ref.watch(teamDaoProvider).watchTeams();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'ARENA CALL-UPS',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Space Grotesk',
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Urgent Dispatch Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFF2B55).withValues(alpha: 0.4),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF2B55).withValues(alpha: 0.12),
                      AppColors.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2B55).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.emergency_share_outlined,
                        color: Color(0xFFFF2B55),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'URGENT ARENA SUMMONS',
                            style: TextStyle(
                              fontFamily: 'Space Grotesk',
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFFFF2B55),
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Triggers a flashing persistent emergency banner on the selected team\'s screens.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Team Selector
              const Text(
                'TARGET TEAM',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<Team>>(
                stream: teamsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  final teams = snapshot.data!;
                  _latestTeams = teams;
                  final selectedTeam = _selectedTeam;
                  if (_selectedTeamId != null && selectedTeam == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _selectedTeamId != null) {
                        setState(() => _selectedTeamId = null);
                      }
                    });
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: AppColors.surfaceAlt,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Space Grotesk',
                        ),
                        isExpanded: true,
                        hint: const Text(
                          'Select a team to summon...',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        value: selectedTeam?.id,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.primary,
                        ),
                        items: teams.map((team) {
                          return DropdownMenuItem<String>(
                            value: team.id,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.precision_manufacturing,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  team.name,
                                  style: const TextStyle(
                                    fontFamily: 'Space Grotesk',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (teamId) {
                          setState(() {
                            _selectedTeamId = teamId;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Urgent Message Field
              const Text(
                'ALERT INSTRUCTION',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Space Grotesk',
                ),
                decoration: InputDecoration(
                  hintText: 'Enter arena summons instruction...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFFF2B55)),
                  ),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Instruction is required'
                    : null,
              ),
              const SizedBox(height: 28),

              // Trigger Button
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: state.isLoading ? null : _submit,
                  icon: state.isLoading
                      ? const SizedBox.shrink()
                      : const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                  label: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'DISPATCH CALL-UP BANNER',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Space Grotesk',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontSize: 14,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2B55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              // Team Members Section
              if (_selectedTeam != null) ...[
                const SizedBox(height: 36),
                Row(
                  children: [
                    const Icon(
                      Icons.contacts_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TEAM MEMBERS // ${_selectedTeam!.name.toUpperCase()}',
                      style: const TextStyle(
                        fontFamily: 'Space Grotesk',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<AppUser>>(
                  stream: ref
                      .watch(userDaoProvider)
                      .watchUsersByTeam(_selectedTeam!.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }

                    final users = snapshot.data!;
                    if (users.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Text(
                            'No team members registered for this team.',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final initials = user.displayName.isNotEmpty
                            ? user.displayName
                                  .trim()
                                  .split(' ')
                                  .map((e) => e.isNotEmpty ? e[0] : '')
                                  .take(2)
                                  .join()
                            : 'U';

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppColors.primary
                                        .withValues(alpha: 0.15),
                                    child: Text(
                                      initials,
                                      style: const TextStyle(
                                        fontFamily: 'Space Grotesk',
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.displayName,
                                          style: const TextStyle(
                                            fontFamily: 'Space Grotesk',
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        if (user.email != null)
                                          Text(
                                            user.email!,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        if (user.phone != null)
                                          Text(
                                            user.phone!,
                                            style: const TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: user.phone != null
                                          ? () => launchUrl(
                                              Uri.parse('tel:${user.phone}'),
                                            )
                                          : null,
                                      icon: const Icon(
                                        Icons.phone_outlined,
                                        size: 14,
                                      ),
                                      label: const Text(
                                        'CALL',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.greenAccent,
                                        side: BorderSide(
                                          color: user.phone != null
                                              ? Colors.greenAccent.withValues(
                                                  alpha: 0.5,
                                                )
                                              : AppColors.border,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 4,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: user.email != null
                                          ? () => launchUrl(
                                              Uri.parse('mailto:${user.email}'),
                                            )
                                          : null,
                                      icon: const Icon(
                                        Icons.email_outlined,
                                        size: 14,
                                      ),
                                      label: const Text(
                                        'EMAIL',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.lightBlueAccent,
                                        side: BorderSide(
                                          color: user.email != null
                                              ? Colors.lightBlueAccent
                                                    .withValues(alpha: 0.5)
                                              : AppColors.border,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 4,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Direct alert dispatched to ${user.displayName}',
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.notifications_active_outlined,
                                        size: 14,
                                      ),
                                      label: const Text(
                                        'NOTIFY',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        side: BorderSide(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 4,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
