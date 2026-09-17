import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AppConfigRepository {
  Stream<String> getMoodMessage();
  Future<void> updateMoodMessage(String newMessage);
}

class FirestoreAppConfigRepository implements AppConfigRepository {
  final FirebaseFirestore _firestore;

  FirestoreAppConfigRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<String> getMoodMessage() {
    return _firestore.collection('config').doc('app_config').snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!['moodMessage'] as String? ?? 'Keep the energy high today!';
      }
      return 'Keep the energy high today!';
    });
  }

  @override
  Future<void> updateMoodMessage(String newMessage) async {
    await _firestore.collection('config').doc('app_config').set(
      {'moodMessage': newMessage},
      SetOptions(merge: true),
    );
  }
}
