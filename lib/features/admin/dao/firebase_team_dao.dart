import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:robowars_app/features/teams/models/team.dart';
import 'package:robowars_app/features/admin/dao/team_dao.dart';

class FirebaseTeamDao implements TeamDao {
  final FirebaseFirestore _firestore;

  FirebaseTeamDao(this._firestore);

  @override
  Stream<List<Team>> watchTeams() {
    return _firestore.collection('teams').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Team.fromFirestore(doc.data(), doc.id)).toList();
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
    await _firestore.collection('teams').doc(teamId).delete();
  }
}
