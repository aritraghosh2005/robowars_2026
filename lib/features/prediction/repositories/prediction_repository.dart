import 'package:cloud_firestore/cloud_firestore.dart';

abstract class PredictionRepository {
  Future<void> submitPrediction({
    required String matchId,
    required String userId,
    required String predictedWinnerTeamId,
    required double pointsMultiplier,
  });

  Stream<Map<String, String>> getUserPredictions(String userId);
}

class FirestorePredictionRepository implements PredictionRepository {
  final FirebaseFirestore _firestore;

  FirestorePredictionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> submitPrediction({
    required String matchId,
    required String userId,
    required String predictedWinnerTeamId,
    required double pointsMultiplier,
  }) async {
    final matchRef = _firestore.collection('matches').doc(matchId);
    final predictionRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('predictions')
        .doc(matchId);

    await _firestore.runTransaction((transaction) async {
      final matchSnapshot = await transaction.get(matchRef);
      if (!matchSnapshot.exists) {
        throw StateError('This match no longer exists.');
      }

      final match = matchSnapshot.data()!;
      final scheduledAt = match['scheduledAt'];
      if (scheduledAt is! Timestamp) {
        throw StateError('Predictions are unavailable until a start time is set.');
      }
      if (Timestamp.now().compareTo(scheduledAt) >= 0 ||
          match['status'] != 'scheduled' ||
          (match['winnerId'] as String? ?? '').isNotEmpty) {
        throw StateError('Predictions closed when this match started.');
      }

      final team1Id = match['team1Id'] as String? ?? '';
      final team2Id = match['team2Id'] as String? ?? '';
      if (predictedWinnerTeamId.isEmpty ||
          (predictedWinnerTeamId != team1Id &&
              predictedWinnerTeamId != team2Id)) {
        throw StateError('Select a valid team for this match.');
      }

      transaction.set(predictionRef, {
        'matchId': matchId,
        'userId': userId,
        'predictedWinnerTeamId': predictedWinnerTeamId,
        'pointsMultiplier': pointsMultiplier,
        'submittedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      }, SetOptions(merge: true));
    });
  }

  @override
  Stream<Map<String, String>> getUserPredictions(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('predictions')
        .snapshots()
        .map((snapshot) {
      final map = <String, String>{};
      for (var doc in snapshot.docs) {
        final winnerId = doc.data()['predictedWinnerTeamId'];
        if (winnerId is String && winnerId.isNotEmpty) {
          map[doc.id] = winnerId;
        }
      }
      return map;
    });
  }
}
