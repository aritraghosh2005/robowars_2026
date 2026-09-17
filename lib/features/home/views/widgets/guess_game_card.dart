import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:robowars_app/core/auth/auth_providers.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/prediction/repositories/prediction_providers.dart';
import 'package:robowars_app/features/schedule/models/match.dart';
import 'package:robowars_app/features/prediction/views/prediction_popup.dart';

class GuessGameCard extends ConsumerStatefulWidget {
  final List<Match> matches;

  const GuessGameCard({
    super.key,
    required this.matches,
  });

  @override
  ConsumerState<GuessGameCard> createState() => _GuessGameCardState();
}

class _GuessGameCardState extends ConsumerState<GuessGameCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _deadlineTimer;

  @override
  void initState() {
    super.initState();
    _deadlineTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant GuessGameCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentPage >= widget.matches.length && widget.matches.isNotEmpty) {
      _currentPage = widget.matches.length - 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_currentPage);
        }
      });
    }
  }

  @override
  void dispose() {
    _deadlineTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = widget.matches.length;
    final predictions = ref.watch(userPredictionsProvider).asData?.value ?? {};
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          // Page content
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalPages,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final match = widget.matches[index];
                final predictedTeamId = predictions[match.id];
                final predictedTeam = predictedTeamId == match.team1Id
                    ? match.team1
                    : predictedTeamId == match.team2Id
                        ? match.team2
                        : null;
                final isPredictionOpen = match.isPredictionOpen;
                return Padding(
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
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              match.category,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${index + 1}/$totalPages',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(child: _teamBlock(match.team1, match.bot1, CrossAxisAlignment.start)),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'VS',
                              style: TextStyle(
                                fontFamily: 'Space Grotesk',
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(child: _teamBlock(match.team2, match.bot2, CrossAxisAlignment.end)),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: isPredictionOpen ? () {
                            final user = ref.read(authStateProvider).asData?.value;
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sign in to predict the winner.'),
                                ),
                              );
                              context.push('/auth');
                              return;
                            }
                            showDialog(
                              context: context,
                              barrierColor: Colors.black87,
                              builder: (context) => PredictionPopup(match: match),
                            );
                          } : null,
                          style: TextButton.styleFrom(
                            backgroundColor: isPredictionOpen
                                ? AppColors.primary
                                : AppColors.surfaceAlt,
                            foregroundColor: Colors.white,
                            disabledForegroundColor: AppColors.textMuted,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isPredictionOpen
                                ? predictedTeam == null
                                    ? 'PREDICT WINNER'
                                    : 'PREDICTED: ${predictedTeam.toUpperCase()}'
                                : 'PREDICTIONS CLOSED',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Dot indicators
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  icon: const Icon(Icons.chevron_left, color: AppColors.textMuted, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                Row(
                  children: List.generate(
                    totalPages,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 6,
                      width: _currentPage == index ? 18 : 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: _currentPage == index ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    if (_currentPage < totalPages - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  icon: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamBlock(String team, String bot, CrossAxisAlignment align) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          team,
          style: const TextStyle(
            fontFamily: 'Space Grotesk',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          bot,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
