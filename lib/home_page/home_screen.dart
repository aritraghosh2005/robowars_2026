import 'package:flutter/material.dart';
import 'package:robowars_app/home_page/guess_game.dart';
import 'package:robowars_app/home_page/live_match.dart';
import 'package:robowars_app/home_page/key_contenders.dart';
import 'package:robowars_app/home_page/quick_stats.dart';
import 'package:robowars_app/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            backgroundColor: AppColors.background,
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            leadingWidth: 56,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: Image.asset(
                'assets/images/app_logo.png',
                fit: BoxFit.contain,
              ),
            ),
            title: const Text(
              "ROBOWARS'26",
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
                child: Icon(
                  Icons.account_circle_outlined,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.border),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Section label
                _sectionLabel('LIVE NOW'),
                const SizedBox(height: 12),
                const LiveMatch(),

                const SizedBox(height: 28),
                _sectionLabel('PREDICT THE WINNER'),
                const SizedBox(height: 12),
                const GuessGame(),

                const SizedBox(height: 28),
                _sectionLabel('KEY CONTENDERS'),
                const SizedBox(height: 12),
                const KeyContenders(
                  contenders: [
                    Contender(
                      name: "Raven (60 kg)",
                      team: "Team Orcus",
                      result: "Wins",
                    ),
                    Contender(
                      name: "Vulcan (15 kg)",
                      team: "Team Orcus",
                      result: "Wins",
                    ),
                  ],
                ),

                const SizedBox(height: 28),
                _sectionLabel('QUICK STATS'),
                const SizedBox(height: 12),
                const QuickStats(
                  stats: {
                    "Matches": "6",
                    "Wins": "4",
                    "Losses": "2",
                    "KOs": "3",
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }
}
