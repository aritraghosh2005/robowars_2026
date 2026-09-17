import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:robowars_app/features/callups/models/callup_item.dart';
import 'package:robowars_app/features/callups/dao/callup_dao.dart';

class FirebaseCallupDao implements CallupDao {
  final FirebaseFirestore _firestore;

  FirebaseCallupDao(this._firestore);

  @override
  Stream<List<CallupItem>> watchCallups() {
    return _firestore
        .collection('callups')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CallupItem.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  @override
  Stream<CallupItem?> watchActiveCallupForTeam(String teamId) {
    return _firestore
        .collection('callups')
        .where('teamId', isEqualTo: teamId)
        .where('isActive', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return CallupItem.fromFirestore(snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    });
  }

  @override
  Future<void> createCallup({required String teamId, required String teamName, required String message}) async {
    await _firestore.collection('callups').add({
      'teamId': teamId,
      'teamName': teamName,
      'message': message,
      'isActive': true,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> dismissCallup(String callupId) async {
    await _firestore.collection('callups').doc(callupId).update({
      'isActive': false,
    });
  }
}
