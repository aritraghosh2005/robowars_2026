import 'package:flutter/material.dart';
import 'package:robowars_app/core/theme/app_theme.dart';

/// Shared SliverAppBar used by all feature screens.
/// Displays the app logo, a page title, and a profile icon.
class CyberSliverAppBar extends StatelessWidget {
  final String title;
  /// Optional callback when the menu/drawer icon is tapped.
  final VoidCallback? onMenuTap;
  /// Optional override for tapping the leading logo. Defaults to opening
  /// the drawer (via [onMenuTap]) when not provided.
  final VoidCallback? onLogoTap;
  /// Shows a hamburger menu action on the trailing side, wired to [onMenuTap].
  final bool showMenuButton;

  const CyberSliverAppBar({
    super.key,
    required this.title,
    this.onMenuTap,
    this.onLogoTap,
    this.showMenuButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return SliverAppBar(
      backgroundColor: AppColors.background,
      floating: true,
      snap: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: canPop ? 56 : 70,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canPop) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => Navigator.pop(context),
            ),
          ] else ...[
            GestureDetector(
              onTap: onLogoTap ?? onMenuTap ?? () => Scaffold.of(context).openDrawer(),
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ],
      ),
      centerTitle: false,
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2.0,
        ),
      ),
      actions: [
        if (showMenuButton)
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: onMenuTap,
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }
}
