import 'package:robowars_app/features/teams/models/team.dart';
import 'package:robowars_app/features/admin/dao/team_dao.dart';

class DummyTeamDao implements TeamDao {
  final List<Team> _teams = [
    const Team(
      id: 'team_1',
      name: 'RoboKnights',
      description: 'The best team from VIT',
      pts: 100,
      wins: 10,
      losses: 2,
      bots: [],
    ),
    const Team(
      id: 'team_2',
      name: 'CircuitBreakers',
      description: 'Circuit crushers',
      pts: 150,
      wins: 15,
      losses: 1,
      bots: [],
    ),
    const Team(
      id: 'team_3',
      name: 'MechaWarriors',
      description: 'Stanford warriors',
      pts: 80,
      wins: 8,
      losses: 4,
      bots: [],
    ),
  ];

  @override
  Stream<List<Team>> watchTeams() async* {
    yield _teams;
  }

  @override
  Future<void> createTeam(Team team) async {
    _teams.add(team);
  }

  @override
  Future<void> updateTeam(Team team) async {
    final index = _teams.indexWhere((t) => t.id == team.id);
    if (index != -1) {
      _teams[index] = team;
    }
  }

  @override
  Future<void> deleteTeam(String teamId) async {
    _teams.removeWhere((t) => t.id == teamId);
  }
}
