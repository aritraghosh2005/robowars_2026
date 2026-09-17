import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:robowars_app/features/teams/models/team.dart';
import 'package:robowars_app/features/admin/dao/team_dao.dart';

class FirebaseTeamDao implements TeamDao {
  final FirebaseFirestore _firestore;

  FirebaseTeamDao(this._firestore);

  @override
  Stream<List<Team>> watchTeams() {
    return _firestore.collection('teams').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Team.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<void> createTeam(Team team) async {
    await _firestore.collection('teams').doc(team.id).set(team.toMap());
  }

  @override
  Future<void> updateTeam(Team team) async {
    await _firestore.collection('teams').doc(team.id).update(team.toMap());
  }

  @override
  Future<void> deleteTeam(String teamId) async {
    final results = await Future.wait([
      _firestore.collection('users').where('teamId', isEqualTo: teamId).get(),
      _firestore
          .collection('participants')
          .where('teamId', isEqualTo: teamId)
          .get(),
    ]);

    final batch = _firestore.batch();
    for (final snapshot in results) {
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'teamId': FieldValue.delete(),
          'teamRole': FieldValue.delete(),
        });
      }
    }
    batch.delete(_firestore.collection('teams').doc(teamId));
    await batch.commit();
  }
}
