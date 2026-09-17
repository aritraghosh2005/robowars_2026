import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:robowars_app/features/auth/models/app_user.dart';
import 'package:robowars_app/features/admin/dao/user_dao.dart';

class FirebaseUserDao implements UserDao {
  final FirebaseFirestore _firestore;

  FirebaseUserDao(this._firestore);

  @override
  Stream<List<AppUser>> watchUsersByTeam(String teamId) {
    return _firestore
        .collection('users')
        .where('teamId', isEqualTo: teamId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AppUser.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
