import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:robowars_app/core/auth/auth_providers.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/home/viewmodels/home_viewmodel.dart';
import 'package:robowars_app/features/home/views/widgets/guess_game_card.dart';
import 'package:robowars_app/features/home/views/widgets/key_contenders_card.dart';
import 'package:robowars_app/features/home/views/widgets/quick_stats_card.dart';
import 'package:robowars_app/shared/widgets/cyber_sliver_app_bar.dart';
import 'package:robowars_app/shared/widgets/section_label.dart';
import 'package:robowars_app/features/notifications/views/notification_drawer.dart';
import 'package:robowars_app/features/schedule/models/match.dart';
import 'package:robowars_app/services/service_providers.dart';

import 'package:robowars_app/shared/widgets/tab_loading_wrapper.dart';

final homePredictionMatchesProvider = StreamProvider<List<Match>>((ref) {
  return ref.watch(matchDaoProvider).watchMatches().map((matches) {
    final upcomingMatches = matches
        .where(
          (match) =>
              match.status == 'scheduled' &&
              match.winner.isEmpty &&
              match.scheduledAt != null,
        )
        .toList();
    upcomingMatches.sort((a, b) => a.scheduledAt!.compareTo(b.scheduledAt!));
    return upcomingMatches;
  });
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final canAccessNotifications = ref.watch(canAccessNotificationsProvider);
    final predictionMatches = ref.watch(homePredictionMatchesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      endDrawer: canAccessNotifications ? const NotificationDrawer() : null,
      body: TabLoadingWrapper(
        controller: _scrollController,
        headerSlivers: [
          // Shared AppBar
          CyberSliverAppBar(
            title: "ROBOWARS'26",
            onLogoTap: _scrollToTop,
            onMenuTap: () => Scaffold.of(context).openDrawer(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: _buildSponsorBanner(),
            ),
          ),
        ],
        contentSlivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Predict the Winner
                const SectionLabel('PREDICT THE WINNER'),
                const SizedBox(height: 12),
                predictionMatches.when(
                  data: (matches) => matches.isEmpty
                      ? const _NoOpenPredictions()
                      : GuessGameCard(matches: matches),
                  loading: () => const SizedBox(
                    height: 160,
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                  error: (_, __) => const _NoOpenPredictions(),
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

  Widget _buildSponsorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          const Text(
            'TITLE SPONSOR',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 14),
          SvgPicture.asset(
            'assets/images/analog_devices_logo.svg',
            height: 56,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}

class _NoOpenPredictions extends StatelessWidget {
  const _NoOpenPredictions();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text(
        'No matches are open for predictions.',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
