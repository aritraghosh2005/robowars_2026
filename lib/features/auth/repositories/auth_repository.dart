import 'package:robowars_app/features/auth/models/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();

  Future<AppUser?> getCurrentUser();

  /// Returns false when the Google account picker is cancelled.
  Future<bool> signInWithGoogle();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sends a Firebase password-reset email to [email].
  /// Throws a user-readable [Exception] on failure.
  Future<void> sendPasswordResetEmail(String email);

  Future<void> completeOnboarding({required String phone});

  Future<void> signOut();
}
