import 'package:flutter/material.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/about/views/about_screen.dart';
import 'package:robowars_app/features/profile/views/profile_screen.dart';
import 'package:robowars_app/features/teams/views/teams_screen.dart';
import 'package:robowars_app/shared/utils/route_transitions.dart';
import 'package:robowars_app/features/shell/views/widgets/audio_visualizer.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
                  final scaffold = Scaffold.of(context);
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    SlideRightRoute(page: const ProfileScreen()),
                  ).then((_) {
                    scaffold.openDrawer();
                  });
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
                      child: const Icon(Icons.person_outline, size: 30, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aritra Ghosh',
                            style: TextStyle(
                              fontFamily: 'Space Grotesk',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'View Profile',
                            style: TextStyle(
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

            const Expanded(
              child: Center(
                child: AudioVisualizer(),
              ),
            ),
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
                  const SizedBox(height: 4),
                  const Text(
                    'Made with ❤️ by RoboVITics',
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
      hoverColor: AppColors.primary.withOpacity(0.1),
    );
  }
}
