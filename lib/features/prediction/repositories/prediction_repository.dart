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
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('predictions')
        .doc(matchId);
        
    await docRef.set({
      'matchId': matchId,
      'predictedWinnerTeamId': predictedWinnerTeamId,
      'pointsMultiplier': pointsMultiplier,
      'submittedAt': FieldValue.serverTimestamp(),
      'status': 'pending', // pending, won, lost
    }, SetOptions(merge: true));
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
        map[doc.id] = doc.data()['predictedWinnerTeamId'] as String;
      }
      return map;
    });
  }
}
