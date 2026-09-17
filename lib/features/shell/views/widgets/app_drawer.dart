import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/about/views/about_screen.dart';
import 'package:robowars_app/features/profile/views/profile_screen.dart';
import 'package:robowars_app/features/teams/views/teams_screen.dart';
import 'package:robowars_app/shared/utils/route_transitions.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:robowars_app/core/auth/auth_providers.dart';
import 'package:robowars_app/features/auth/models/app_user.dart';
import 'package:robowars_app/features/admin/auth/admin_service.dart';
import 'package:robowars_app/services/service_providers.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final roleState = ref.watch(roleServiceProvider).asData?.value;
    final isAdmin = roleState?.service is AdminService || user?.role == UserRole.admin;
    return Drawer(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context); // close drawer
                  if (user == null) {
                    context.push('/auth');
                  } else {
                    // Navigate to profile if logged in
                    Navigator.push(
                      context,
                      SlideRightRoute(page: const ProfileScreen()),
                    );
                  }
                },
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: user?.avatarUrl != null
                          ? Image.network(user!.avatarUrl!, fit: BoxFit.cover)
                          : const Icon(Icons.person_outline, size: 30, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Guest',
                            style: const TextStyle(
                              fontFamily: 'Space Grotesk',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user != null ? user.role.name : 'Sign In',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 16),

            // Navigation Items
            _buildDrawerItem(
              icon: Icons.groups_outlined,
              title: 'TEAMS',
              onTap: () {
                final scaffold = Scaffold.of(context);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  SlideRightRoute(page: const TeamScreen()),
                ).then((_) {
                  scaffold.openDrawer();
                });
              },
            ),
            _buildDrawerItem(
              icon: Icons.info_outline_rounded,
              title: 'ABOUT & SPONSORS',
              onTap: () {
                final scaffold = Scaffold.of(context);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  SlideRightRoute(page: const AboutScreen()),
                ).then((_) {
                  scaffold.openDrawer();
                });
              },
            ),
            if (isAdmin)
              _buildDrawerItem(
                icon: Icons.shield_outlined,
                title: 'ADMIN CONSOLE',
                onTap: () {
                  final scaffold = Scaffold.of(context);
                  Navigator.pop(context);
                  context.push('/admin').then((_) {
                    if (scaffold.mounted) scaffold.openDrawer();
                  });
                },
              ),

            const Spacer(),
            const Divider(color: AppColors.border, height: 1),
            // Footer
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Image.asset('assets/images/app_logo.png', height: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'Robowars 2026',
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Powered by',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: AppColors.textMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => launchUrl(Uri.parse('https://www.analog.com/en/index.html')),
                    // No-tagline wordmark variant — the tagline is dropped here specifically.
                    child: SvgPicture.asset(
                      'assets/images/g10.svg',
                      height: 48,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Made by RoboVITics',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: AppColors.textSecondary, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.5,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      hoverColor: AppColors.primary.withValues(alpha: 0.1),
    );
  }
}
