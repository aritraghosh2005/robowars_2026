import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:robowars_app/features/auth/models/app_user.dart';
import 'package:robowars_app/features/admin/dao/user_dao.dart';

class FirebaseUserDao implements UserDao {
  final FirebaseFirestore _firestore;

  FirebaseUserDao(this._firestore);

  @override
  Stream<List<AppUser>> watchUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      final users = snapshot.docs
          .map((doc) => AppUser.fromMap(doc.data(), doc.id))
          .toList();
      users.sort(
        (a, b) =>
            a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
      );
      return users;
    });
  }

  @override
  Stream<List<AppUser>> watchUsersByTeam(String teamId) {
    return _firestore
        .collection('users')
        .where('teamId', isEqualTo: teamId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AppUser.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  @override
  Future<void> assignParticipantToTeam(AppUser user, String teamId) async {
    final participants = _firestore.collection('participants');
    final participantDoc = await _findParticipantDocument(user);
    final teamRole = participantDoc?.data()['teamRole'] as String? ?? 'Member';

    final participantRef =
        participantDoc?.reference ?? participants.doc(user.uid);
    final batch = _firestore.batch();
    batch.set(_firestore.collection('users').doc(user.uid), {
      'role': UserRole.participant.name,
      'teamId': teamId,
      'teamRole': teamRole,
    }, SetOptions(merge: true));
    batch.set(participantRef, {
      'uid': user.uid,
      'fullName': user.displayName,
      if (user.email != null) 'email': user.email!.trim().toLowerCase(),
      if (user.phone != null) 'phone': user.phone,
      'teamId': teamId,
      'teamRole': teamRole,
      'isActive': true,
      if (participantDoc == null) 'registeredAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
  }

  @override
  Future<void> setTeamAdmin(AppUser user, bool isTeamAdmin) async {
    final participantDoc = await _findParticipantDocument(user);
    if (participantDoc == null) {
      throw StateError('Participant record not found.');
    }

    final teamRole = isTeamAdmin ? 'Team Admin' : 'Member';
    final batch = _firestore.batch();
    batch.set(_firestore.collection('users').doc(user.uid), {
      'teamRole': teamRole,
    }, SetOptions(merge: true));
    batch.set(participantDoc.reference, {
      'teamRole': teamRole,
      'isActive': true,
    }, SetOptions(merge: true));
    await batch.commit();
  }

  @override
  Future<void> removeParticipant(AppUser user) async {
    final participantDoc = await _findParticipantDocument(user);
    final batch = _firestore.batch();
    batch.set(_firestore.collection('users').doc(user.uid), {
      'role': UserRole.viewer.name,
      'teamId': FieldValue.delete(),
      'teamRole': FieldValue.delete(),
    }, SetOptions(merge: true));
    if (participantDoc != null) {
      batch.set(participantDoc.reference, {
        'isActive': false,
        'teamId': FieldValue.delete(),
        'teamRole': FieldValue.delete(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> _findParticipantDocument(
    AppUser user,
  ) async {
    final participants = _firestore.collection('participants');
    final byUid = await participants
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .get();
    if (byUid.docs.isNotEmpty) return byUid.docs.first;

    if (user.email == null) return null;
    final byEmail = await participants
        .where('email', isEqualTo: user.email!.trim().toLowerCase())
        .limit(1)
        .get();
    return byEmail.docs.isEmpty ? null : byEmail.docs.first;
  }
}
