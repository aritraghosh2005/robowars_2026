import 'package:robowars_app/features/notifications/models/notification_item.dart';
import 'package:robowars_app/features/notifications/dao/notification_dao.dart';
import 'package:uuid/uuid.dart';

class DummyNotificationDao implements NotificationDao {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: 'notif1',
      title: 'Welcome Participants!',
      content: 'Please ensure you check in at the registration desk by 9:00 AM.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  @override
  Stream<List<NotificationItem>> watchNotifications() {
    return Stream.value([..._notifications]);
  }

  @override
  Future<void> createNotification(String title, String content) async {
    _notifications.insert(0, NotificationItem(
      id: const Uuid().v4(),
      title: title,
      content: content,
      timestamp: DateTime.now(),
    ));
  }
}
