import 'package:intl/intl.dart';
import 'package:robowars_app/features/teams/models/bot_category.dart';

/// A single match in the schedule.
class Match {
  final String id;
  final String team1;
  final String bot1;
  final String team2;
  final String bot2;
  final String category;
  final String time;
  final DateTime? scheduledAt;
  final String winner;
  final String team1Id;
  final String team2Id;
  final String winnerId;
  final int team1Points;
  final int team2Points;
  final String status;
  final bool pointsApplied;

  const Match({
    required this.id,
    required this.team1,
    required this.bot1,
    required this.team2,
    required this.bot2,
    required this.category,
    required this.time,
    this.scheduledAt,
    required this.winner,
    this.team1Id = '',
    this.team2Id = '',
    this.winnerId = '',
    this.team1Points = 0,
    this.team2Points = 0,
    this.status = 'scheduled',
    this.pointsApplied = false,
  });

  Match copyWith({
    String? id,
    String? team1,
    String? bot1,
    String? team2,
    String? bot2,
    String? category,
    String? time,
    DateTime? scheduledAt,
    String? winner,
    String? team1Id,
    String? team2Id,
    String? winnerId,
    int? team1Points,
    int? team2Points,
    String? status,
    bool? pointsApplied,
  }) {
    return Match(
      id: id ?? this.id,
      team1: team1 ?? this.team1,
      bot1: bot1 ?? this.bot1,
      team2: team2 ?? this.team2,
      bot2: bot2 ?? this.bot2,
      category: category ?? this.category,
      time: time ?? this.time,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      winner: winner ?? this.winner,
      team1Id: team1Id ?? this.team1Id,
      team2Id: team2Id ?? this.team2Id,
      winnerId: winnerId ?? this.winnerId,
      team1Points: team1Points ?? this.team1Points,
      team2Points: team2Points ?? this.team2Points,
      status: status ?? this.status,
      pointsApplied: pointsApplied ?? this.pointsApplied,
    );
  }

  factory Match.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Match(
      id: documentId,
      team1: data['team1'] ?? '',
      bot1: data['bot1'] ?? '',
      team2: data['team2'] ?? '',
      bot2: data['bot2'] ?? '',
      category: BotCategory.normalize(data['category'] as String?),
      time: data['time'] ?? '',
      scheduledAt: _parseDate(data['scheduledAt']),
      winner: data['winner'] ?? '',
      team1Id: data['team1Id'] ?? '',
      team2Id: data['team2Id'] ?? '',
      winnerId: data['winnerId'] ?? '',
      team1Points: (data['team1Points'] as num?)?.toInt() ?? 0,
      team2Points: (data['team2Points'] as num?)?.toInt() ?? 0,
      status: data['status'] ?? 'scheduled',
      pointsApplied: data['pointsApplied'] == true,
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
      'scheduledAt': scheduledAt,
      'winner': winner,
      'team1Id': team1Id,
      'team2Id': team2Id,
      'winnerId': winnerId,
      'team1Points': team1Points,
      'team2Points': team2Points,
      'winnerPoints': winnerId == team1Id ? team1Points : team2Points,
      'loserPoints': winnerId == team1Id ? team2Points : team1Points,
      'status': status,
      'pointsApplied': pointsApplied,
    };
  }

  bool get isPredictionOpen {
    final start = scheduledAt;
    return status == 'scheduled' &&
        winner.isEmpty &&
        start != null &&
        DateTime.now().isBefore(start);
  }

  String get displayTime {
    final start = scheduledAt;
    if (start == null) return time.isEmpty ? 'TBD' : time;
    return DateFormat('dd MMM yyyy, hh:mm a').format(start);
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    try {
      final converted = value.toDate();
      return converted is DateTime ? converted : null;
    } catch (_) {
      return null;
    }
  }
}
