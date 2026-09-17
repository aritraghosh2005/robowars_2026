import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:robowars_app/core/auth/auth_providers.dart';

part 'auth_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class AuthViewModel extends _$AuthViewModel {
  @override
  FutureOr<void> build() {
    // Initial state is just empty void since authStateChanges drives the real state
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithGoogle();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signInWithAdmin(String email, String password) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithEmailAndPassword(email: email, password: password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Sends a Firebase password-reset email for the given admin [email].
  /// Returns the error message string on failure, or null on success.
  Future<String?> resetAdminPassword(String email) async {
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.sendPasswordResetEmail(email);
      return null; // success
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
