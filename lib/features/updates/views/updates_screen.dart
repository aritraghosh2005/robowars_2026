import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/core/auth/auth_providers.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/updates/models/update_item.dart';
import 'package:robowars_app/features/updates/viewmodels/updates_viewmodel.dart';
import 'package:robowars_app/shared/widgets/cyber_sliver_app_bar.dart';
import 'package:robowars_app/features/notifications/views/notification_drawer.dart';

import 'package:robowars_app/shared/widgets/tab_loading_wrapper.dart';

class UpdatesScreen extends ConsumerWidget {
  const UpdatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updates = ref.watch(updatesViewModelProvider);
    final canAccessNotifications = ref.watch(canAccessNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      endDrawer: canAccessNotifications ? const NotificationDrawer() : null,
      body: TabLoadingWrapper(
        headerSlivers: [
          CyberSliverAppBar(
            title: 'UPDATES',
            onMenuTap: () => Scaffold.of(context).openDrawer(),
          ),
        ],
        contentSlivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            sliver: updates.when(
              data: (updatesData) {
                if (updatesData.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Text('No updates yet.', style: TextStyle(color: Colors.white)),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildUpdateCard(updatesData[index]),
                    childCount: updatesData.length,
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (e, st) => SliverToBoxAdapter(
                child: Center(
                  child: Text('Error loading updates: $e', style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard(UpdateItem update) {
    final tagColor = update.tag.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar with tag + time
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tagColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: tagColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    update.tag.label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: tagColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  update.time,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  update.title,
                  style: const TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  update.content,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
