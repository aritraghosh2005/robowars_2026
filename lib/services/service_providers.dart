import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:robowars_app/core/auth/auth_providers.dart';
import 'package:robowars_app/core/auth/role_mode.dart';
import 'package:robowars_app/features/auth/models/app_user.dart';
import 'package:robowars_app/features/participant/auth/participant_service.dart';
import 'package:robowars_app/features/admin/auth/admin_service.dart';
import 'package:robowars_app/features/viewer/auth/viewer_service.dart';
import 'package:robowars_app/features/admin/dao/match_dao.dart';
import 'package:robowars_app/features/admin/dao/team_dao.dart';
import 'package:robowars_app/features/admin/dao/firebase_match_dao.dart';
import 'package:robowars_app/features/admin/dao/dummy_match_dao.dart';
import 'package:robowars_app/features/admin/dao/firebase_team_dao.dart';
import 'package:robowars_app/features/admin/dao/dummy_team_dao.dart';
import 'package:robowars_app/features/updates/dao/update_dao.dart';
import 'package:robowars_app/features/updates/dao/firebase_update_dao.dart';
import 'package:robowars_app/features/updates/dao/dummy_update_dao.dart';
import 'package:robowars_app/features/notifications/dao/notification_dao.dart';
import 'package:robowars_app/features/notifications/dao/firebase_notification_dao.dart';
import 'package:robowars_app/features/notifications/dao/dummy_notification_dao.dart';
import 'package:robowars_app/features/callups/dao/callup_dao.dart';
import 'package:robowars_app/features/callups/dao/firebase_callup_dao.dart';
import 'package:robowars_app/features/callups/dao/dummy_callup_dao.dart';
import 'package:robowars_app/features/admin/dao/user_dao.dart';
import 'package:robowars_app/features/admin/dao/firebase_user_dao.dart';
import 'package:robowars_app/features/admin/dao/dummy_user_dao.dart';

enum ServiceBackend { firebase, dummy }

final backendProvider = Provider<ServiceBackend>(
  (ref) => ServiceBackend.firebase,
);

final matchDaoProvider = Provider<MatchDao>((ref) {
  final backend = ref.watch(backendProvider);
  if (backend == ServiceBackend.firebase) {
    return FirebaseMatchDao(FirebaseFirestore.instance);
  } else {
    return DummyMatchDao();
  }
});

final teamDaoProvider = Provider<TeamDao>((ref) {
  final backend = ref.watch(backendProvider);
  if (backend == ServiceBackend.firebase) {
    return FirebaseTeamDao(FirebaseFirestore.instance);
  } else {
    return DummyTeamDao();
  }
});

final updateDaoProvider = Provider<UpdateDao>((ref) {
  final backend = ref.watch(backendProvider);
  if (backend == ServiceBackend.firebase) {
    return FirebaseUpdateDao(FirebaseFirestore.instance);
  } else {
    return DummyUpdateDao();
  }
});

final notificationDaoProvider = Provider<NotificationDao>((ref) {
  final backend = ref.watch(backendProvider);
  if (backend == ServiceBackend.firebase) {
    return FirebaseNotificationDao(FirebaseFirestore.instance);
  } else {
    return DummyNotificationDao();
  }
});

final callupDaoProvider = Provider<CallupDao>((ref) {
  final backend = ref.watch(backendProvider);
  if (backend == ServiceBackend.firebase) {
    return FirebaseCallupDao(FirebaseFirestore.instance);
  } else {
    return DummyCallupDao();
  }
});

final userDaoProvider = Provider<UserDao>((ref) {
  final backend = ref.watch(backendProvider);
  if (backend == ServiceBackend.firebase) {
    return FirebaseUserDao(FirebaseFirestore.instance);
  } else {
    return DummyUserDao();
  }
});

class RoleServiceState {
  final Object? service;
  final bool hasError;
  final String? errorMessage;

  RoleServiceState({this.service, this.hasError = false, this.errorMessage});
}

final roleServiceProvider = FutureProvider<RoleServiceState>((ref) async {
  try {
    final user = ref.watch(authStateProvider).asData?.value;
    final roleMode = ref.watch(activeRoleModeProvider);

    // No Firebase session — use the active debug role mode.
    if (user == null) {
      switch (roleMode) {
        case RoleMode.admin:
          final service = AdminService();
          await service.initialize();
          return RoleServiceState(service: service);
        case RoleMode.participant:
          final service = ParticipantService();
          await service.initialize();
          return RoleServiceState(service: service);
        case RoleMode.viewer:
          final service = ViewerService();
          await service.initialize();
          return RoleServiceState(service: service);
      }
    }

    switch (user.role) {
      case UserRole.admin:
        final service = AdminService();
        await service.initialize();
        return RoleServiceState(service: service);
      case UserRole.participant:
        final service = ParticipantService();
        await service.initialize();
        return RoleServiceState(service: service);
      default:
        final service = ViewerService();
        await service.initialize();
        return RoleServiceState(service: service);
    }
  } catch (e) {
    // If initialization fails, flag as error so the router can catch it
    return RoleServiceState(hasError: true, errorMessage: e.toString());
  }
});
