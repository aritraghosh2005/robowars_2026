import 'package:robowars_app/features/auth/models/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  
  Future<AppUser?> getCurrentUser();

  Future<void> signInWithGoogle();
  
  Future<void> verifyPhoneNumber(
    String phoneNumber, {
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(String error) verificationFailed,
  });

  Future<void> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  });

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sends a Firebase password-reset email to [email].
  /// Throws a user-readable [Exception] on failure.
  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();
}
