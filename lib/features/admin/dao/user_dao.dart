import 'package:robowars_app/features/auth/models/app_user.dart';

abstract class UserDao {
  Stream<List<AppUser>> watchUsersByTeam(String teamId);
}
