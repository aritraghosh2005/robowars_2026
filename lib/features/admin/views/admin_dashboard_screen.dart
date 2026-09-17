import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/services/service_providers.dart';
import 'package:robowars_app/features/admin/auth/admin_service.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleState = ref.watch(roleServiceProvider).asData?.value;
    if (roleState == null || roleState.service is! AdminService) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text(
            'Permission denied: Not an admin',
            style: TextStyle(
              color: Colors.red,
              fontFamily: 'Space Grotesk',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'ADMIN CONSOLE',
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2.0,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    AppColors.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                    ),
                    child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'PRIVILEGED ACCESS',
                              style: TextStyle(
                                fontFamily: 'Space Grotesk',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Arena Control & Comms',
                          style: TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Padding(
              padding: EdgeInsets.only(left: 4.0, bottom: 12.0),
              child: Text(
                'ARENA OPERATIONS',
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            _buildAdminCard(
              context,
              title: 'Manage Matches',
              subtitle: 'Schedule, edit, or configure arena battles',
              category: 'MATCHES',
              icon: Icons.sports_esports_outlined,
              onTap: () => context.push('/admin/matches'),
            ),
            const SizedBox(height: 12),
            _buildAdminCard(
              context,
              title: 'Manage Teams & Bots',
              subtitle: 'Register teams, weight classes, and bot stats',
              category: 'ROSTER',
              icon: Icons.groups_outlined,
              onTap: () => context.push('/admin/teams'),
            ),
            const SizedBox(height: 12),
            _buildAdminCard(
              context,
              title: 'Set Match Winners',
              subtitle: 'Decide victorious teams and award tournament points',
              category: 'RESULTS',
              icon: Icons.emoji_events_outlined,
              accentColor: Colors.amber,
              onTap: () => context.push('/admin/winners'),
            ),

            const SizedBox(height: 28),
            const Padding(
              padding: EdgeInsets.only(left: 4.0, bottom: 12.0),
              child: Text(
                'BROADCAST & DISPATCH',
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            _buildAdminCard(
              context,
              title: 'Updates Composer',
              subtitle: 'Publish arena feeds and public event logs',
              category: 'FEED',
              icon: Icons.campaign_outlined,
              onTap: () => context.push('/admin/updates'),
            ),
            const SizedBox(height: 12),
            _buildAdminCard(
              context,
              title: 'Notification Sender',
              subtitle: 'Push high-priority alerts to all participants',
              category: 'PUSH',
              icon: Icons.notifications_active_outlined,
              onTap: () => context.push('/admin/notifications'),
            ),
            const SizedBox(height: 12),
            _buildAdminCard(
              context,
              title: 'Team Call-ups & Dispatch',
              subtitle: 'Urgent arena summons with direct call/email actions',
              category: 'URGENT',
              icon: Icons.emergency_share_outlined,
              accentColor: const Color(0xFFFF2B55),
              onTap: () => context.push('/admin/callups'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String category,
    required IconData icon,
    required VoidCallback onTap,
    Color? accentColor,
  }) {
    final effectiveAccent = accentColor ?? AppColors.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: effectiveAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: effectiveAccent.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: effectiveAccent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: effectiveAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: effectiveAccent,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
