import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:robowars_app/core/theme/app_theme.dart';

/// Shared SliverAppBar used by all feature screens.
/// Displays the app logo, a page title, and a profile icon.
class CyberSliverAppBar extends StatelessWidget {
  final String title;
  /// Optional callback when the menu/drawer icon is tapped.
  final VoidCallback? onMenuTap;
  /// Optional override for tapping the trailing logo. Defaults to null.
  final VoidCallback? onLogoTap;

  const CyberSliverAppBar({
    super.key,
    required this.title,
    this.onMenuTap,
    this.onLogoTap,
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
      leadingWidth: 56,
      leading: canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => Navigator.pop(context),
            )
          : IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primary),
              onPressed: onMenuTap ?? () => Scaffold.of(context).openDrawer(),
            ),
      centerTitle: true,
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
        IconButton(
          icon: const Badge(
            backgroundColor: Colors.red,
            child: Icon(Icons.notifications, color: Colors.white),
          ),
          onPressed: () => Scaffold.of(context).openEndDrawer(),
        ),
        GestureDetector(
          onTap: onLogoTap,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: SvgPicture.asset(
              'assets/images/robowars_logo.svg',
              fit: BoxFit.contain,
              width: 40,
              colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }
}
