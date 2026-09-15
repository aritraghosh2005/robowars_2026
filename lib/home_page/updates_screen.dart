import 'package:flutter/material.dart';
import 'package:robowars_app/theme/app_theme.dart';

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  final List<Map<String, String>> _updates = const [
    {
      'title': 'Round 1 Results: Featherweight',
      'content': 'Team Orcus\'s "Raven" clinched victory in a stunning KO against "Byte Crusher". The bot\'s spinner was unstoppable.',
      'time': '2 hrs ago',
      'tag': 'RESULTS',
    },
    {
      'title': 'Match Delayed: Arena Inspection',
      'content': 'The heavyweight bout between Team Shadow and Team Nexus has been delayed by 30 minutes for arena safety checks.',
      'time': '3 hrs ago',
      'tag': 'ALERT',
    },
    {
      'title': 'Schedule Update: Day 2',
      'content': 'The semifinals bracket has been updated. Check the Schedule tab for the latest matchup times and pairings.',
      'time': '5 hrs ago',
      'tag': 'UPDATE',
    },
    {
      'title': 'KO of the Day: Firestorm Dominates',
      'content': 'Team Blaze\'s "Firestorm" delivered the most spectacular KO of the day, launching "Ice Breaker" 3 feet into the air.',
      'time': '6 hrs ago',
      'tag': 'HIGHLIGHT',
    },
    {
      'title': 'Registration Reminder',
      'content': 'Walk-in registrations close tonight at 10 PM. All competing teams must verify their bot weight at the check-in desk.',
      'time': '8 hrs ago',
      'tag': 'INFO',
    },
    {
      'title': 'Day 1 Recap: 12 Matches Completed',
      'content': 'A thrilling Day 1 saw 12 matches across all weight classes. The Featherweight category had the most upsets so far.',
      'time': '10 hrs ago',
      'tag': 'RECAP',
    },
  ];

  Color _tagColor(String tag) {
    switch (tag) {
      case 'RESULTS': return AppColors.primary;
      case 'ALERT': return const Color(0xFFFF6B2B);
      case 'UPDATE': return const Color(0xFF2B9EFF);
      case 'HIGHLIGHT': return const Color(0xFFFFD700);
      case 'INFO': return const Color(0xFF7B61FF);
      case 'RECAP': return const Color(0xFF2BFFA0);
      default: return AppColors.textMuted;
    }
  }

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
            title: const Text(
              'UPDATES',
              style: TextStyle(
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

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildUpdateCard(index),
                childCount: _updates.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard(int index) {
    final update = _updates[index];
    final tag = update['tag']!;
    final tagColor = _tagColor(tag);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar with tag + time
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tagColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: tagColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: tagColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  update['time']!,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  update['title']!,
                  style: const TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  update['content']!,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}