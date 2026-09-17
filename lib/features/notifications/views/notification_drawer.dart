import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/notifications/models/notification_item.dart';
import 'package:robowars_app/services/service_providers.dart';

class NotificationDrawer extends ConsumerWidget {
  const NotificationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsStream = ref.watch(notificationDaoProvider).watchNotifications();

    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Text(
                    'NOTIFICATIONS',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Space Grotesk',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<NotificationItem>>(
                stream: notificationsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  
                  final notifications = snapshot.data!;
                  if (notifications.isEmpty) {
                    return const Center(
                      child: Text(
                        'No notifications yet.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const Divider(color: AppColors.border),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.content,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatTime(item.timestamp),
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
