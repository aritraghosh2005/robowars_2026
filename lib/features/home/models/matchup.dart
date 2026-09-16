/// Represents a single matchup in the Predict the Winner game.
class Matchup {
  final String team1;
  final String bot1;
  final String team2;
  final String bot2;
  final String category;

  const Matchup({
    required this.team1,
    required this.bot1,
    required this.team2,
    required this.bot2,
    required this.category,
  });
}
