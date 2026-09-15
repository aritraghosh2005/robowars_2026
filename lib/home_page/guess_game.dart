import 'package:flutter/material.dart';
import 'package:robowars_app/home_page/pop_up.dart';
import 'package:robowars_app/theme/app_theme.dart';

class GuessGame extends StatefulWidget {
  const GuessGame({super.key});

  @override
  State<GuessGame> createState() => _GuessGameState();
}

class _GuessGameState extends State<GuessGame> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int totalPages = 6;

  // Mock matchup data
  final List<Map<String, String>> _matchups = [
    {'team1': 'Team Shadow', 'bot1': 'Dark Matter', 'team2': 'Team Apex', 'bot2': 'Apex Predator', 'category': '60 kg'},
    {'team1': 'Team Phoenix', 'bot1': 'Inferno', 'team2': 'Team Nexus', 'bot2': 'Cyclone', 'category': '15 kg'},
    {'team1': 'Team Orcus', 'bot1': 'Raven', 'team2': 'Team Venom', 'bot2': 'Serpent', 'category': '8 kg'},
    {'team1': 'Team Thunder', 'bot1': 'Bolt', 'team2': 'Team Titan', 'bot2': 'Colossus', 'category': '60 kg'},
    {'team1': 'Team Blaze', 'bot1': 'Firestorm', 'team2': 'Team Ice', 'bot2': 'Glacier', 'category': '15 kg'},
    {'team1': 'Team Steel', 'bot1': 'Iron Will', 'team2': 'Team Ghost', 'bot2': 'Phantom', 'category': '8 kg'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                final m = _matchups[index % _matchups.length];
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
                              m['category']!,
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
                          Expanded(
                            child: _teamBlock(m['team1']!, m['bot1']!, CrossAxisAlignment.start),
                          ),
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
                          Expanded(
                            child: _teamBlock(m['team2']!, m['bot2']!, CrossAxisAlignment.end),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => const PopUpCard(),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'PREDICT WINNER',
                            style: TextStyle(
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
