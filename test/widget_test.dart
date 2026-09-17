import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robowars_app/core/auth/auth_providers.dart';
import 'package:robowars_app/features/auth/models/app_user.dart';
import 'package:robowars_app/features/auth/repositories/auth_repository.dart';
import 'package:robowars_app/features/auth/views/auth_screen.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<AppUser?> authStateChanges() => Stream.value(null);

  @override
  Future<AppUser?> getCurrentUser() async => null;

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> completeOnboarding({required String phone}) async {}

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<bool> signInWithGoogle() async => false;

  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('shows one login page with email and Google options', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        ],
        child: const MaterialApp(home: AuthScreen()),
      ),
    );

    expect(find.text('Welcome to Robowars'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('PARTICIPANT'), findsNothing);
    expect(find.text('ADMIN'), findsNothing);
  });
}
