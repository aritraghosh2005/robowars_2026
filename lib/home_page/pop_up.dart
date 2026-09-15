import 'package:flutter/material.dart';
import 'package:robowars_app/home_page/leaderboard.dart';
import 'package:robowars_app/home_page/prediction.dart';
import 'package:robowars_app/theme/app_theme.dart';

class PopUpCard extends StatefulWidget {
  const PopUpCard({super.key});

  @override
  State<PopUpCard> createState() => _PopUpCardState();
}

class _PopUpCardState extends State<PopUpCard> with TickerProviderStateMixin {
  late AnimationController _controller;
  late TabController _tabController;
  late Animation<double> _scaleAnimation;
  bool _isPredictionExpanded = false;
  bool _isLeaderboardTabActive = false;

  void _handlePredictionExpand(bool isExpanded) {
    setState(() => _isPredictionExpanded = isExpanded);
  }

  void _handleTabSelection() {
    setState(() {
      _isLeaderboardTabActive = _tabController.index == 1;
      if (_tabController.index == 1) _isPredictionExpanded = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double currentHeight = _isLeaderboardTabActive
        ? 550
        : _isPredictionExpanded
            ? 350
            : 280;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: BoxConstraints(maxWidth: 380, maxHeight: currentHeight),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PREDICT WINNER',
                        style: TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tab bar
                  Container(
                    height: 36,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textMuted,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        color: AppColors.primary,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      tabs: const [
                        Tab(text: 'Predict'),
                        Tab(text: 'Leaderboard'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        SingleChildScrollView(
                          child: PredictionTab(
                            onTabClicked: () => setState(() => _isLeaderboardTabActive = false),
                            onExpandChanged: _handlePredictionExpand,
                          ),
                        ),
                        LeaderboardTab(
                          onTabClicked: () => setState(() {
                            _isLeaderboardTabActive = true;
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
