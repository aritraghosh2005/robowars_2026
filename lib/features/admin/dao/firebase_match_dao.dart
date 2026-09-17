import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:robowars_app/features/schedule/models/match.dart';
import 'package:robowars_app/features/admin/dao/match_dao.dart';

class FirebaseMatchDao implements MatchDao {
  final FirebaseFirestore _firestore;

  FirebaseMatchDao(this._firestore);

  @override
  Stream<List<Match>> watchMatches() {
    return _firestore.collection('matches').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Match.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> createMatch(Match match) async {
    await _firestore.collection('matches').doc(match.id).set(match.toMap());
  }

  @override
  Future<void> updateMatch(Match match) async {
    await _firestore.collection('matches').doc(match.id).update(match.toMap());
  }

  @override
  Future<void> deleteMatch(String matchId) async {
    await _firestore.collection('matches').doc(matchId).delete();
  }
}
