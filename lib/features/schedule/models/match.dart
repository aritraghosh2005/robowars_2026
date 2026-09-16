/// A single match in the schedule.
class Match {
  final String team1;
  final String bot1;
  final String team2;
  final String bot2;
  final String category;
  final String time;
  final String winner;

  const Match({
    required this.team1,
    required this.bot1,
    required this.team2,
    required this.bot2,
    required this.category,
    required this.time,
    required this.winner,
  });
}
