import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RoleMode { viewer, participant, admin }

class RoleModeNotifier extends Notifier<RoleMode> {
  @override
  RoleMode build() => RoleMode.viewer;

  void setRole(RoleMode mode) => state = mode;
}

final activeRoleModeProvider = NotifierProvider<RoleModeNotifier, RoleMode>(RoleModeNotifier.new);
