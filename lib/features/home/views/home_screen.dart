import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/home/viewmodels/home_viewmodel.dart';
import 'package:robowars_app/features/home/views/widgets/guess_game_card.dart';
import 'package:robowars_app/features/home/views/widgets/key_contenders_card.dart';
import 'package:robowars_app/features/home/views/widgets/quick_stats_card.dart';
import 'package:robowars_app/shared/widgets/cyber_sliver_app_bar.dart';
import 'package:robowars_app/shared/widgets/section_label.dart';

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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Shared AppBar
          CyberSliverAppBar(
            title: "ROBOWARS'26",
            onLogoTap: _scrollToTop,
            showMenuButton: true,
            onMenuTap: () => Scaffold.of(context).openDrawer(),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Sponsor banner — RoboVITics 15th anniversary mark
                _buildSponsorBanner(),
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
