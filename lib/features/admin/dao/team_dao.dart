import 'package:robowars_app/features/teams/models/team.dart';

/// Data Access Object (DAO) for Team-related database operations.
abstract class TeamDao {
  /// Stream of all teams.
  Stream<List<Team>> watchTeams();
  
  /// Create a new team.
  Future<void> createTeam(Team team);
  
  /// Update an existing team.
  Future<void> updateTeam(Team team);
  
  /// Delete a team.
  Future<void> deleteTeam(String teamId);
}
