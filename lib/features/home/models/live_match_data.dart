/// Represents the current live match data.
class LiveMatchData {
  final String team1Name;
  final String team1Bot;
  final String team2Name;
  final String team2Bot;
  final bool isLive;

  const LiveMatchData({
    required this.team1Name,
    required this.team1Bot,
    required this.team2Name,
    required this.team2Bot,
    this.isLive = true,
  });
}
