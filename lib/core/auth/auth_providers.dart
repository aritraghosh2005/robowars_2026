import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/core/firebase/firebase_providers.dart';
import 'package:robowars_app/core/auth/role_mode.dart';
import 'package:robowars_app/features/auth/models/app_user.dart';
import 'package:robowars_app/features/auth/repositories/auth_repository.dart';
import 'package:robowars_app/features/auth/repositories/firebase_auth_repository.dart';
import 'package:robowars_app/services/fcm_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final fcmService = FcmService();
  return authRepository.authStateChanges().asyncMap((user) async {
    try {
      if (user != null) {
        await fcmService.subscribeBasedOnRole(user);
      } else {
        await fcmService.clearSubscriptions();
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Could not update FCM subscriptions: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
    return user;
  });
});

final currentUserProvider = Provider<AppUser?>((ref) {
  final firebaseUser = ref.watch(authStateProvider).asData?.value;
  if (firebaseUser != null) return firebaseUser;

  // No Firebase session — inject a mock user matching the active debug role.
  final roleMode = ref.watch(activeRoleModeProvider);
  final now = DateTime.now();

  switch (roleMode) {
    case RoleMode.participant:
      return AppUser(
        uid: 'user_debug_participant',
        displayName: 'Alice Pilot',
        email: 'alice@roboknights.com',
        phone: '+15551234567',
        role: UserRole.participant,
        teamId: 'team_1',
        createdAt: now,
        lastLoginAt: now,
      );
    case RoleMode.admin:
      return AppUser(
        uid: 'user_debug_admin',
        displayName: 'Admin (Debug)',
        email: 'admin@robowars.com',
        role: UserRole.admin,
        createdAt: now,
        lastLoginAt: now,
      );
    case RoleMode.viewer:
      return null; // Viewer has no user profile
  }
});

final canAccessNotificationsProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null && user.role != UserRole.viewer;
});
