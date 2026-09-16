import 'package:robowars_app/features/teams/models/bot.dart';

/// Represents a team participating in Robowars.
class Team {
  final String name;
  final List<Bot> bots;
  final String description;
  final int wins;
  final int losses;
  final int pts;

  const Team({
    required this.name,
    required this.bots,
    required this.description,
    required this.wins,
    required this.losses,
    required this.pts,
  });
}
