class Prediction {
  final String id;
  final String matchId;
  final String predictedWinnerTeamId;
  final String userId;
  final int pointsMultiplier;
  final DateTime createdAt;
  final String status; // 'pending', 'won', 'lost'

  Prediction({
    required this.id,
    required this.matchId,
    required this.predictedWinnerTeamId,
    required this.userId,
    required this.pointsMultiplier,
    required this.createdAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'predictedWinnerTeamId': predictedWinnerTeamId,
      'userId': userId,
      'pointsMultiplier': pointsMultiplier,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory Prediction.fromMap(Map<String, dynamic> map, String id) {
    return Prediction(
      id: id,
      matchId: map['matchId'] ?? '',
      predictedWinnerTeamId: map['predictedWinnerTeamId'] ?? '',
      userId: map['userId'] ?? '',
      pointsMultiplier: map['pointsMultiplier']?.toInt() ?? 1,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      status: map['status'] ?? 'pending',
    );
  }
}
