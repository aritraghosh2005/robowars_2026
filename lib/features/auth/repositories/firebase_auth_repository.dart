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
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  // ---------------------------------------------------------------------------
  // Auth State Stream
  // ---------------------------------------------------------------------------

  @override
  Stream<AppUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          return AppUser.fromMap(doc.data()!, doc.id);
        }
        // No document yet — create a basic one so the stream never hangs
        return _buildBasicUser(user);
      } catch (e) {
        // Offline or Firestore not yet set up — return a minimal user object
        return _buildBasicUser(user);
      }
    });
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
  // Google Sign-In  (Viewers)
  // ---------------------------------------------------------------------------

  @override
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return; // user cancelled

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _firebaseAuth.signInWithCredential(credential);
    final firebaseUser = userCred.user!;

    // Check admin status exclusively via the Firestore admins allowlist.
    // No hardcoded emails — all admin grants are managed server-side.
    UserRole assignedRole = UserRole.viewer;
    if (firebaseUser.email != null) {
      try {
        final adminQuery = await _firestore
            .collection('admins')
            .where('email', isEqualTo: firebaseUser.email)
            .limit(1)
            .get();
        if (adminQuery.docs.isNotEmpty) {
          assignedRole = UserRole.admin;
        }
      } catch (e) {
        debugPrint('[AuthRepository] Admin check failed: $e');
      }
    }

    await _ensureUserDocument(
      firebaseUser,
      role: assignedRole,
      forceRoleUpdate: assignedRole == UserRole.admin,
    );
  }

  // ---------------------------------------------------------------------------
  // Phone / OTP  (Participants)
  // ---------------------------------------------------------------------------

  @override
  Future<void> verifyPhoneNumber(
    String phoneNumber, {
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(String error) verificationFailed,
  }) async {
    // Step 1: Check participant registration directly in Firestore (no Cloud Function needed)
    try {
      final query = await _firestore
          .collection('participants')
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        verificationFailed('This phone number is not registered as a participant.');
        return;
      }
    } catch (e) {
      verificationFailed('Could not verify registration: $e');
      return;
    }

    // Step 2: Proceed with Firebase Phone Auth
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential cred) async {
        final userCred = await _firebaseAuth.signInWithCredential(cred);
        await _ensureUserDocument(userCred.user!, role: UserRole.participant);
      },
      verificationFailed: (FirebaseAuthException e) {
        verificationFailed(e.message ?? 'Verification failed');
      },
      codeSent: codeSent,
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  @override
  Future<void> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final userCred = await _firebaseAuth.signInWithCredential(credential);
    await _ensureUserDocument(userCred.user!, role: UserRole.participant);
  }

  // ---------------------------------------------------------------------------
  // Email / Password  (Admins)
  // ---------------------------------------------------------------------------

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Step 1: Verify the email exists in the sealed admins allowlist.
    // Use a flag so intentional "not an admin" exceptions are never swallowed
    // by the Firestore network-error catch block.
    bool isAdminVerified = false;
    try {
      final adminQuery = await _firestore
          .collection('admins')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      isAdminVerified = adminQuery.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Could not reach the admin list. Check your connection.');
    }

    if (!isAdminVerified) {
      throw Exception('This email is not registered as an admin.');
    }

    // Step 2: Sign in with standard Firebase Email/Password Auth.
    // Admin accounts must be pre-created in Firebase Console → Authentication → Users.
    // If a password has never been set, use "Forgot Password?" to receive a reset link.
    try {
      final userCred = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _ensureUserDocument(
        userCred.user!,
        role: UserRole.admin,
        forceRoleUpdate: true,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          // Firebase v6+ returns invalid-credential for: wrong password,
          // account not found, or no email/password credential linked.
          throw Exception(
            'Wrong password, or no password has been set for this account. '
            'Use "Forgot Password?" to receive a reset link.',
          );
        case 'user-not-found':
          throw Exception(
            'No Firebase Auth account found for this email. '
            'Create it in Firebase Console → Authentication → Users.',
          );
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
    // Guard: only send to addresses in the admins allowlist.
    try {
      final adminQuery = await _firestore
          .collection('admins')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (adminQuery.docs.isEmpty) {
        throw Exception('This email is not registered as an admin.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Could not reach the admin list. Check your connection.');
    }

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception(
            'No Firebase Auth account found. '
            'Create it in Firebase Console → Authentication → Users first.',
          );
        case 'too-many-requests':
          throw Exception('Too many requests. Wait a few minutes and try again.');
        default:
          throw Exception('Could not send reset email: ${e.message}');
      }
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

  /// Ensures a `users/{uid}` document exists. Creates one on first login.
  /// Always refreshes `lastLoginAt` and the FCM token on every login.
  Future<void> _ensureUserDocument(
    User firebaseUser, {
    required UserRole role,
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
      String? teamId;
      if (role == UserRole.participant && firebaseUser.phoneNumber != null) {
        try {
          final pQuery = await _firestore
              .collection('participants')
              .where('phone', isEqualTo: firebaseUser.phoneNumber)
              .limit(1)
              .get();
          if (pQuery.docs.isNotEmpty) {
            teamId = pQuery.docs.first.data()['teamId'] as String?;
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
        teamId: teamId,
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
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }
}
