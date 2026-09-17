import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:robowars_app/features/auth/models/app_user.dart';
import 'package:robowars_app/features/auth/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  // ---------------------------------------------------------------------------
  // Auth State Stream
  // ---------------------------------------------------------------------------

  @override
  Stream<AppUser?> authStateChanges() {
    late final StreamController<AppUser?> controller;
    StreamSubscription<User?>? authSubscription;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
    userSubscription;

    Future<void> watchUser(User? firebaseUser) async {
      await userSubscription?.cancel();
      userSubscription = null;
      if (controller.isClosed) return;

      if (firebaseUser == null) {
        controller.add(null);
        return;
      }

      userSubscription = _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots()
          .listen(
            (doc) {
              if (controller.isClosed) return;
              final data = doc.data();
              controller.add(
                data == null
                    ? _buildBasicUser(firebaseUser)
                    : AppUser.fromMap(data, doc.id),
              );
            },
            onError: (_) {
              if (!controller.isClosed) {
                controller.add(_buildBasicUser(firebaseUser));
              }
            },
          );
    }

    controller = StreamController<AppUser?>();
    controller.onListen = () {
      authSubscription = _firebaseAuth.authStateChanges().listen(watchUser);
    };
    controller.onCancel = () async {
      await userSubscription?.cancel();
      await authSubscription?.cancel();
      await controller.close();
    };
    return controller.stream;
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(doc.data()!, doc.id);
      }
    } catch (_) {}
    return _buildBasicUser(user);
  }

  // ---------------------------------------------------------------------------
  // Google Sign-In
  // ---------------------------------------------------------------------------

  @override
  Future<bool> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return false;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _firebaseAuth.signInWithCredential(credential);
    await _assignRoleAndUser(userCred.user!);
    return true;
  }

  // ---------------------------------------------------------------------------
  // Email / Password
  // ---------------------------------------------------------------------------

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCred = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      await _assignRoleAndUser(userCred.user!);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          // Firebase v6+ returns invalid-credential for: wrong password,
          // account not found, or no email/password credential linked.
          throw Exception(
            'Incorrect email or password. Use "Forgot password?" if needed.',
          );
        case 'user-not-found':
          throw Exception('No account was found for this email.');
        case 'too-many-requests':
          throw Exception('Too many failed attempts. Try again later.');
        default:
          throw Exception('Login failed: ${e.message}');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Password Reset
  // ---------------------------------------------------------------------------

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: email.trim().toLowerCase(),
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No account was found for this email.');
        case 'too-many-requests':
          throw Exception(
            'Too many requests. Wait a few minutes and try again.',
          );
        default:
          throw Exception('Could not send reset email: ${e.message}');
      }
    }
  }

  @override
  Future<void> completeOnboarding({required String phone}) async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      throw Exception('Sign in again to complete your profile.');
    }

    final normalizedPhone = _normalizePhone(phone);
    final userRef = _firestore.collection('users').doc(firebaseUser.uid);
    await userRef.set({
      'phone': normalizedPhone,
      'onboardingCompleted': true,
      'onboardingCompletedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    try {
      var participantSnapshot = await _firestore
          .collection('participants')
          .where('uid', isEqualTo: firebaseUser.uid)
          .limit(1)
          .get();
      final email = firebaseUser.email?.trim().toLowerCase();
      if (participantSnapshot.docs.isEmpty && email != null) {
        participantSnapshot = await _firestore
            .collection('participants')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
      }
      if (participantSnapshot.docs.isNotEmpty) {
        await participantSnapshot.docs.first.reference.set({
          'uid': firebaseUser.uid,
          'phone': normalizedPhone,
        }, SetOptions(merge: true));
      }
    } catch (error) {
      debugPrint('[AuthRepository] Participant phone sync failed: $error');
    }
  }

  // ---------------------------------------------------------------------------
  // Sign Out
  // ---------------------------------------------------------------------------

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _assignRoleAndUser(User firebaseUser) async {
    try {
      final resolved = await _resolveRoleFromFirestore(firebaseUser);
      await _ensureUserDocument(
        firebaseUser,
        role: resolved.role,
        teamId: resolved.teamId,
        teamRole: resolved.teamRole,
        forceRoleUpdate: true,
      );
      await firebaseUser.getIdToken(true);
    } catch (_) {
      await _firebaseAuth.signOut();
      throw Exception('Could not determine account role. Try again.');
    }
  }

  Future<({UserRole role, String? teamId, String? teamRole})>
  _resolveRoleFromFirestore(User firebaseUser) async {
    final email = firebaseUser.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) {
      return (role: UserRole.viewer, teamId: null, teamRole: null);
    }

    final adminSnapshot = await _firestore
        .collection('admins')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (adminSnapshot.docs.isNotEmpty) {
      return (role: UserRole.admin, teamId: null, teamRole: null);
    }

    final participantSnapshot = await _firestore
        .collection('participants')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (participantSnapshot.docs.isNotEmpty) {
      final participant = participantSnapshot.docs.first;
      final participantData = participant.data();
      if (participantData['isActive'] == false) {
        return (role: UserRole.viewer, teamId: null, teamRole: null);
      }
      await participant.reference.update({'uid': firebaseUser.uid});
      return (
        role: UserRole.participant,
        teamId: participantData['teamId'] as String?,
        teamRole: participantData['teamRole'] as String?,
      );
    }

    return (role: UserRole.viewer, teamId: null, teamRole: null);
  }

  /// Ensures a `users/{uid}` document exists. Creates one on first login.
  /// Always refreshes `lastLoginAt` and the FCM token on every login.
  Future<void> _ensureUserDocument(
    User firebaseUser, {
    required UserRole role,
    String? teamId,
    String? teamRole,
    bool forceRoleUpdate = false,
  }) async {
    final ref = _firestore.collection('users').doc(firebaseUser.uid);
    final doc = await ref.get();

    // Fetch a fresh FCM token for push notification targeting.
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('[AuthRepository] FCM token fetch failed: $e');
    }

    if (!doc.exists) {
      // Look up participant data if role is participant
      var resolvedTeamId = teamId;
      if (resolvedTeamId == null &&
          role == UserRole.participant &&
          firebaseUser.phoneNumber != null) {
        try {
          final pQuery = await _firestore
              .collection('participants')
              .where('phone', isEqualTo: firebaseUser.phoneNumber)
              .limit(1)
              .get();
          if (pQuery.docs.isNotEmpty) {
            resolvedTeamId = pQuery.docs.first.data()['teamId'] as String?;
            // Link uid back to the participant doc
            await pQuery.docs.first.reference.update({'uid': firebaseUser.uid});
          }
        } catch (_) {}
      }

      final now = DateTime.now();
      final appUser = AppUser(
        uid: firebaseUser.uid,
        displayName: firebaseUser.displayName ?? firebaseUser.email ?? 'User',
        email: firebaseUser.email,
        phone: firebaseUser.phoneNumber,
        avatarUrl: firebaseUser.photoURL,
        role: role,
        fcmToken: fcmToken,
        teamId: resolvedTeamId,
        teamRole: teamRole,
        onboardingCompleted: false,
        createdAt: now,
        lastLoginAt: now,
      );
      await ref.set(appUser.toMap());
    } else {
      // Update last login timestamp (as Firestore Timestamp, not ISO string)
      // and refresh FCM token and optionally force role update.
      final updates = <String, dynamic>{
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
        if (fcmToken != null) 'fcmToken': fcmToken,
        if (forceRoleUpdate) 'role': role.name,
        if (forceRoleUpdate) 'teamId': teamId,
        if (forceRoleUpdate) 'teamRole': teamRole,
      };
      await ref.update(updates);
    }
  }

  AppUser _buildBasicUser(User firebaseUser) {
    return AppUser(
      uid: firebaseUser.uid,
      displayName: firebaseUser.displayName ?? firebaseUser.email ?? 'User',
      email: firebaseUser.email,
      phone: firebaseUser.phoneNumber,
      avatarUrl: firebaseUser.photoURL,
      role: UserRole.viewer,
      onboardingCompleted: false,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  String _normalizePhone(String phone) {
    final trimmed = phone.trim();
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 7 || digits.length > 15) {
      throw Exception('Enter a valid phone number with country code.');
    }
    return trimmed.startsWith('+') ? '+$digits' : digits;
  }
}
