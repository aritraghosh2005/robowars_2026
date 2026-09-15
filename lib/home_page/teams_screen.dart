import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:robowars_app/theme/app_theme.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  bool _isTeamsSelected = true;

  final List<Map<String, dynamic>> _teamsData = List.generate(
    8,
    (i) => {
      'name': ['Team Orcus', 'Team Shadow', 'Team Phoenix', 'Team Nexus', 'Team Thunder', 'Team Titan', 'Team Blaze', 'Team Ice'][i],
      'bots': [
        {'name': ['Raven', 'Dark Matter', 'Inferno', 'Cyclone', 'Bolt', 'Colossus', 'Firestorm', 'Glacier'][i], 'weight': ['60 kg', '15 kg', '8 kg', '60 kg', '15 kg', '8 kg', '60 kg', '15 kg'][i]},
        {'name': ['Vulcan', 'Phantom', 'Blaze', 'Storm', 'Thunder', 'Golem', 'Ember', 'Frost'][i], 'weight': ['15 kg', '8 kg', '60 kg', '15 kg', '8 kg', '60 kg', '15 kg', '8 kg'][i]},
      ],
      'description': 'A battle-hardened team from across the nation, bringing precision-engineered war machines designed for maximum impact in the arena.',
      'wins': [4, 3, 5, 2, 4, 1, 3, 2][i],
      'losses': [1, 2, 0, 3, 2, 4, 2, 3][i],
      'pts': [8, 6, 10, 4, 8, 2, 6, 4][i],
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            leadingWidth: 56,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: Image.asset('assets/images/app_logo.png', fit: BoxFit.contain),
            ),
            title: Text(
              _isTeamsSelected ? 'TEAMS' : 'STANDINGS',
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(Icons.account_circle_outlined, color: AppColors.primary, size: 30),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.border),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: _buildToggle(),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            sliver: _isTeamsSelected ? _buildTeamsList() : _buildTableView(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _toggleButton('Teams', true),
          _toggleButton('Standings', false),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool forTeams) {
    final isSelected = _isTeamsSelected == forTeams;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isTeamsSelected = forTeams),
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

  SliverList _buildTeamsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final team = _teamsData[index];
          final bots = team['bots'] as List;
          return GestureDetector(
            onTap: () => _showTeamPopup(context, team),
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
                          team['name'],
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
                          children: bots.map<Widget>((bot) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                              ),
                              child: Text(
                                '${bot['name']} · ${bot['weight']}',
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
        childCount: _teamsData.length,
      ),
    );
  }

  SliverList _buildTableView() {
    final sorted = [..._teamsData]..sort((a, b) => (b['pts'] as int).compareTo(a['pts'] as int));
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
                  // Rank
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
                  // Team name
                  Expanded(
                    child: Text(
                      team['name'],
                      style: const TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // Stats
                  _statCol('M', '${team['wins'] + team['losses']}'),
                  const SizedBox(width: 16),
                  _statCol('W', '${team['wins']}'),
                  const SizedBox(width: 16),
                  _statCol('L', '${team['losses']}'),
                  const SizedBox(width: 16),
                  _statColHighlight('PTS', '${team['pts']}'),
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

  void _showTeamPopup(BuildContext context, Map<String, dynamic> team) {
    showGeneralDialog(
      context: context,
      barrierLabel: 'Team',
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              team['name'],
                              style: const TextStyle(
                                fontFamily: 'Space Grotesk',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bots
                          const Text(
                            'BOTS',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (team['bots'] as List).map<Widget>((bot) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  '${bot['name']}  ·  ${bot['weight']}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'ABOUT',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            team['description'],
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Stats row
                          Row(
                            children: [
                              _popupStat('Wins', '${team['wins']}'),
                              _popupStat('Losses', '${team['losses']}'),
                              _popupStat('Points', '${team['pts']}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _popupStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}