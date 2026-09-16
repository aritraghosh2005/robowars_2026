import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/home/viewmodels/home_viewmodel.dart';
import 'package:robowars_app/features/home/views/widgets/guess_game_card.dart';
import 'package:robowars_app/features/home/views/widgets/key_contenders_card.dart';
import 'package:robowars_app/features/home/views/widgets/live_match_card.dart';
import 'package:robowars_app/features/home/views/widgets/quick_stats_card.dart';
import 'package:robowars_app/shared/widgets/cyber_sliver_app_bar.dart';
import 'package:robowars_app/shared/widgets/section_label.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Shared AppBar
          CyberSliverAppBar(
            title: "ROBOWARS'26",
            onMenuTap: () => Scaffold.of(context).openDrawer(),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Live Match
                const SectionLabel('LIVE NOW'),
                const SizedBox(height: 12),
                LiveMatchCard(data: state.liveMatch),

                const SizedBox(height: 28),
                // Predict the Winner
                const SectionLabel('PREDICT THE WINNER'),
                const SizedBox(height: 12),
                GuessGameCard(
                  matchups: state.matchups,
                  totalPages: state.matchups.length,
                ),

                const SizedBox(height: 28),
                // Key Contenders
                const SectionLabel('KEY CONTENDERS'),
                const SizedBox(height: 12),
                KeyContendersCard(contenders: state.contenders),

                const SizedBox(height: 28),
                // Quick Stats
                const SectionLabel('QUICK STATS'),
                const SizedBox(height: 12),
                QuickStatsCard(stats: state.quickStats),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
