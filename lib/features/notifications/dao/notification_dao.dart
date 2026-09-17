import 'package:robowars_app/features/notifications/models/notification_item.dart';

abstract class NotificationDao {
  Stream<List<NotificationItem>> watchNotifications();
  Future<void> createNotification(String title, String content);
}
