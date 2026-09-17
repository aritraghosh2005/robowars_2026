import 'package:robowars_app/features/teams/models/bot.dart';

/// Represents a team participating in Robowars.
class Team {
  final String id;
  final String name;
  final List<Bot> bots;
  final String description;
  final int wins;
  final int losses;
  final int pts;

  const Team({
    required this.id,
    required this.name,
    required this.bots,
    required this.description,
    required this.wins,
    required this.losses,
    required this.pts,
  });

  factory Team.fromFirestore(Map<String, dynamic> data, String documentId) {
    var botsList = (data['bots'] as List<dynamic>? ?? [])
        .map((e) => Bot.fromMap(e as Map<String, dynamic>))
        .toList();

    return Team(
      id: documentId,
      name: data['name'] ?? '',
      bots: botsList,
      description: data['description'] ?? '',
      wins: data['wins'] ?? 0,
      losses: data['losses'] ?? 0,
      pts: data['pts'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bots': bots.map((b) => b.toMap()).toList(),
      'description': description,
      'wins': wins,
      'losses': losses,
      'pts': pts,
    };
  }
}
