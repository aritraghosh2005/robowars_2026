import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:robowars_app/features/updates/models/update_item.dart';
import 'package:robowars_app/features/updates/dao/update_dao.dart';

class FirebaseUpdateDao implements UpdateDao {
  final FirebaseFirestore _firestore;

  FirebaseUpdateDao(this._firestore);

  @override
  Stream<List<UpdateItem>> watchUpdates() {
    return _firestore
        .collection('updates')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UpdateItem.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<void> createUpdate(UpdateItem update) async {
    await _firestore.collection('updates').add({
      'title': update.title,
      'content': update.content,
      'time': update.time,
      'tag': update.tag.name,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteUpdate(String updateId) async {
    await _firestore.collection('updates').doc(updateId).delete();
  }
}
