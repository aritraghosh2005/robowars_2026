import 'package:robowars_app/features/auth/models/app_user.dart';

abstract class UserDao {
  Stream<List<AppUser>> watchUsers();

  Stream<List<AppUser>> watchUsersByTeam(String teamId);

  Future<void> assignParticipantToTeam(AppUser user, String teamId);

  Future<void> setTeamAdmin(AppUser user, bool isTeamAdmin);

  Future<void> removeParticipant(AppUser user);
}
