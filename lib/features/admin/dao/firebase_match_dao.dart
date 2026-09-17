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
  Future<void> saveMatchResult(Match match) async {
    if (match.team1Id.isEmpty || match.team2Id.isEmpty) {
      throw StateError('Both teams must have valid Firestore IDs.');
    }
    if (match.status == 'completed' && match.winnerId.isEmpty) {
      throw StateError('Select a winner before completing the match.');
    }

    final matchRef = _firestore.collection('matches').doc(match.id);
    final team1Ref = _firestore.collection('teams').doc(match.team1Id);
    final team2Ref = _firestore.collection('teams').doc(match.team2Id);

    await _firestore.runTransaction((transaction) async {
      final snapshots = await Future.wait([
        transaction.get(matchRef),
        transaction.get(team1Ref),
        transaction.get(team2Ref),
      ]);
      final currentMatch = snapshots[0].exists
          ? Match.fromFirestore(snapshots[0].data()!, match.id)
          : match;
      if (!snapshots[1].exists || !snapshots[2].exists) {
        throw StateError('One of the selected teams no longer exists.');
      }

      var team1PointsDelta = 0;
      var team2PointsDelta = 0;
      var team1WinsDelta = 0;
      var team1LossesDelta = 0;
      var team2WinsDelta = 0;
      var team2LossesDelta = 0;

      if (currentMatch.pointsApplied) {
        team1PointsDelta -= currentMatch.team1Points;
        team2PointsDelta -= currentMatch.team2Points;
        if (currentMatch.winnerId == currentMatch.team1Id) {
          team1WinsDelta--;
          team2LossesDelta--;
        } else if (currentMatch.winnerId == currentMatch.team2Id) {
          team2WinsDelta--;
          team1LossesDelta--;
        }
      }

      final applyingResult = match.status == 'completed';
      if (applyingResult) {
        team1PointsDelta += match.team1Points;
        team2PointsDelta += match.team2Points;
        if (match.winnerId == match.team1Id) {
          team1WinsDelta++;
          team2LossesDelta++;
        } else {
          team2WinsDelta++;
          team1LossesDelta++;
        }
      }

      transaction.update(team1Ref, {
        'pts': FieldValue.increment(team1PointsDelta),
        'wins': FieldValue.increment(team1WinsDelta),
        'losses': FieldValue.increment(team1LossesDelta),
      });
      transaction.update(team2Ref, {
        'pts': FieldValue.increment(team2PointsDelta),
        'wins': FieldValue.increment(team2WinsDelta),
        'losses': FieldValue.increment(team2LossesDelta),
      });
      transaction.set(
        matchRef,
        match.copyWith(pointsApplied: applyingResult).toMap(),
        SetOptions(merge: true),
      );
    });
  }

  @override
  Future<void> deleteMatch(String matchId) async {
    final matchRef = _firestore.collection('matches').doc(matchId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(matchRef);
      if (!snapshot.exists) return;

      final match = Match.fromFirestore(snapshot.data()!, snapshot.id);
      if (match.pointsApplied &&
          match.team1Id.isNotEmpty &&
          match.team2Id.isNotEmpty) {
        final team1Ref = _firestore.collection('teams').doc(match.team1Id);
        final team2Ref = _firestore.collection('teams').doc(match.team2Id);
        final team1Snapshot = await transaction.get(team1Ref);
        final team2Snapshot = await transaction.get(team2Ref);

        if (team1Snapshot.exists) {
          transaction.update(team1Ref, {
            'pts': FieldValue.increment(-match.team1Points),
            'wins': FieldValue.increment(
              match.winnerId == match.team1Id ? -1 : 0,
            ),
            'losses': FieldValue.increment(
              match.winnerId == match.team2Id ? -1 : 0,
            ),
          });
        }
        if (team2Snapshot.exists) {
          transaction.update(team2Ref, {
            'pts': FieldValue.increment(-match.team2Points),
            'wins': FieldValue.increment(
              match.winnerId == match.team2Id ? -1 : 0,
            ),
            'losses': FieldValue.increment(
              match.winnerId == match.team1Id ? -1 : 0,
            ),
          });
        }
      }

      transaction.delete(matchRef);
    });
  }
}
