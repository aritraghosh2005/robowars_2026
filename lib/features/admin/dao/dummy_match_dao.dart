import 'package:robowars_app/features/schedule/models/match.dart';
import 'package:robowars_app/features/admin/dao/match_dao.dart';

class DummyMatchDao implements MatchDao {
  final List<Match> _matches = [
    const Match(
      id: '1',
      team1: 'RoboKnights',
      bot1: 'KnightTron',
      team2: 'MechaWarriors',
      bot2: 'MechZ',
      category: '15kg',
      time: '10:00 AM',
      winner: '',
    ),
    const Match(
      id: '2',
      team1: 'CircuitBreakers',
      bot1: 'Breaker',
      team2: 'IronClad',
      bot2: 'IronFist',
      category: '60kg',
      time: '11:30 AM',
      winner: 'CircuitBreakers',
    ),
  ];

  @override
  Stream<List<Match>> watchMatches() async* {
    yield _matches;
  }

  @override
  Future<void> createMatch(Match match) async {
    _matches.add(match);
  }

  @override
  Future<void> updateMatch(Match match) async {
    final index = _matches.indexWhere((m) => m.id == match.id);
    if (index != -1) {
      _matches[index] = match;
    }
  }

  @override
  Future<void> saveMatchResult(Match match) => updateMatch(match);

  @override
  Future<void> deleteMatch(String matchId) async {
    _matches.removeWhere((m) => m.id == matchId);
  }
}
