import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:robowars_app/features/notifications/models/notification_item.dart';
import 'package:robowars_app/features/notifications/dao/notification_dao.dart';

class FirebaseNotificationDao implements NotificationDao {
  final FirebaseFirestore _firestore;

  FirebaseNotificationDao(this._firestore);

  @override
  Stream<List<NotificationItem>> watchNotifications() {
    return _firestore
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationItem.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> createNotification(String title, String content) async {
    await _firestore.collection('notifications').add({
      'title': title,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'deliveryStatus': 'queued',
    });
  }
}
