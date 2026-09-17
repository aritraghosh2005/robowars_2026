import 'dart:async';
import 'package:robowars_app/features/auth/models/app_user.dart';
import 'package:robowars_app/features/admin/dao/user_dao.dart';

class DummyUserDao implements UserDao {
  final List<AppUser> _dummyUsers = [
    AppUser(
      uid: 'user1',
      displayName: 'Alice Pilot',
      email: 'alice@roboknights.com',
      phone: '+15551234567',
      role: UserRole.participant,
      teamId: 'team_1',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      lastLoginAt: DateTime.now(),
    ),
    AppUser(
      uid: 'user2',
      displayName: 'Bob Builder',
      email: 'bob@roboknights.com',
      phone: '+15559876543',
      role: UserRole.participant,
      teamId: 'team_1',
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
      lastLoginAt: DateTime.now(),
    ),
    AppUser(
      uid: 'user3',
      displayName: 'Charlie Cyber',
      email: 'charlie@cybertitans.com',
      phone: '+15551112222',
      role: UserRole.participant,
      teamId: 'team_2',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      lastLoginAt: DateTime.now(),
    ),
  ];

  @override
  Stream<List<AppUser>> watchUsersByTeam(String teamId) {
    // Return a stream that emits the list of users belonging to the team
    return Stream.value(_dummyUsers.where((u) => u.teamId == teamId).toList());
  }
}
