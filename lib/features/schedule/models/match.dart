/// A single match in the schedule.
class Match {
  final String id;
  final String team1;
  final String bot1;
  final String team2;
  final String bot2;
  final String category;
  final String time;
  final String winner;

  const Match({
    required this.id,
    required this.team1,
    required this.bot1,
    required this.team2,
    required this.bot2,
    required this.category,
    required this.time,
    required this.winner,
  });

  Match copyWith({
    String? id,
    String? team1,
    String? bot1,
    String? team2,
    String? bot2,
    String? category,
    String? time,
    String? winner,
  }) {
    return Match(
      id: id ?? this.id,
      team1: team1 ?? this.team1,
      bot1: bot1 ?? this.bot1,
      team2: team2 ?? this.team2,
      bot2: bot2 ?? this.bot2,
      category: category ?? this.category,
      time: time ?? this.time,
      winner: winner ?? this.winner,
    );
  }

  factory Match.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Match(
      id: documentId,
      team1: data['team1'] ?? '',
      bot1: data['bot1'] ?? '',
      team2: data['team2'] ?? '',
      bot2: data['bot2'] ?? '',
      category: data['category'] ?? '',
      time: data['time'] ?? '',
      winner: data['winner'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'team1': team1,
      'bot1': bot1,
      'team2': team2,
      'bot2': bot2,
      'category': category,
      'time': time,
      'winner': winner,
    };
  }
}
