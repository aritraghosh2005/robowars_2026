import 'package:robowars_app/features/schedule/models/match.dart';

/// Data Access Object (DAO) for Match-related database operations.
abstract class MatchDao {
  /// Stream of all matches.
  Stream<List<Match>> watchMatches();
  
  /// Create a new match.
  Future<void> createMatch(Match match);
  
  /// Update an existing match.
  Future<void> updateMatch(Match match);

  /// Applies or clears a result while keeping team totals idempotent.
  Future<void> saveMatchResult(Match match);
  
  /// Delete a match.
  Future<void> deleteMatch(String matchId);
}
