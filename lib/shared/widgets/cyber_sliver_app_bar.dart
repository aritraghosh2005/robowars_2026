import 'package:flutter/material.dart';
import 'package:robowars_app/core/theme/app_theme.dart';

/// Shared SliverAppBar used by all feature screens.
/// Displays the app logo, a page title, and a profile icon.
class CyberSliverAppBar extends StatelessWidget {
  final String title;
  /// Optional callback when the menu/drawer icon is tapped.
  final VoidCallback? onMenuTap;

  const CyberSliverAppBar({
    super.key,
    required this.title,
    this.onMenuTap,
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
              onTap: onMenuTap ?? () => Scaffold.of(context).openDrawer(),
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }
}
