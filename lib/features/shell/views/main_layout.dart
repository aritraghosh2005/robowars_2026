import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/home/views/home_screen.dart';
import 'package:robowars_app/features/schedule/views/schedule_screen.dart';
import 'package:robowars_app/features/shell/viewmodels/navigation_viewmodel.dart';
import 'package:robowars_app/features/shell/views/widgets/app_drawer.dart';
import 'package:robowars_app/features/updates/views/updates_screen.dart';
import 'package:robowars_app/shared/widgets/offline_banner.dart';
import 'package:robowars_app/features/callups/views/callup_banner.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  static const List<Widget> _pages = [
    HomeScreen(),
    Schedule(),
    UpdatesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationViewModelProvider);

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          const CallupBanner(),
          const OfflineBanner(),
          Expanded(child: _pages[currentIndex]),
        ],
      ),
      bottomNavigationBar: _buildNavBar(context, currentIndex),
    );
  }

  Widget _buildNavBar(BuildContext context, int currentIndex) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: EdgeInsets.only(
        top: 6,
        left: 8,
        right: 8,
        bottom: bottomPad > 0 ? bottomPad : 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(0, Icons.home_rounded, 'Home', currentIndex),
          _navItem(1, Icons.calendar_month_rounded, 'Schedule', currentIndex),
          _navItem(2, Icons.campaign_rounded, 'Updates', currentIndex),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, int currentIndex) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () {
        ref.read(navigationViewModelProvider.notifier).setIndex(index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textMuted,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
