import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/core/auth/auth_providers.dart';
import 'package:robowars_app/features/shell/views/main_layout.dart';
import 'package:robowars_app/features/splash/views/splash_screen.dart';
import 'package:robowars_app/features/auth/views/auth_screen.dart';
import 'package:robowars_app/features/auth/views/onboarding_screen.dart';
import 'package:robowars_app/features/admin/views/admin_dashboard_screen.dart';
import 'package:robowars_app/features/admin/views/match_editor_screen.dart';
import 'package:robowars_app/features/admin/views/team_editor_screen.dart';
import 'package:robowars_app/features/admin/views/participant_manager_screen.dart';
import 'package:robowars_app/features/admin/views/match_winners_screen.dart';
import 'package:robowars_app/features/admin/views/notification_sender_screen.dart';
import 'package:robowars_app/features/admin/views/callup_sender_screen.dart';
import 'package:robowars_app/features/admin/views/update_composer_screen.dart';
import 'package:robowars_app/features/admin/auth/admin_service.dart';
import 'package:robowars_app/services/service_providers.dart';

final _routerRefreshProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, __) => notifier.value++);
  ref.listen(roleServiceProvider, (_, __) => notifier.value++);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(_routerRefreshProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final roleServiceState = ref.read(roleServiceProvider);

      // While auth is still loading, do nothing.
      if (authState.isLoading) return null;

      final user = authState.asData?.value;
      final onSplashPage = state.matchedLocation == '/splash';
      final onAuthPage = state.matchedLocation == '/auth';
      final onOnboardingPage = state.matchedLocation == '/onboarding';

      // Let the opening animation finish before applying auth redirects.
      if (onSplashPage) return null;

      if (user == null && onOnboardingPage) return '/auth';

      final needsOnboarding =
          user != null &&
          (!user.onboardingCompleted ||
              user.phone == null ||
              user.phone!.trim().isEmpty);
      if (needsOnboarding && !onOnboardingPage) return '/onboarding';
      if (needsOnboarding) return null;
      if (user != null && onOnboardingPage) return '/home';

      // If the role service errored, fall back to auth.
      if (roleServiceState.asData?.value.hasError == true) {
        return onAuthPage ? null : '/auth';
      }

      // Logged-in user sitting on the auth page → send home.
      if (user != null && onAuthPage) return '/home';

      // Protect admin routes.
      final isAdmin = roleServiceState.asData?.value.service is AdminService;
      if (state.matchedLocation.startsWith('/admin') && !isAdmin) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const MainLayout()),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/admin',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 260),
          child: const AdminDashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final position = Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation);
            return SlideTransition(position: position, child: child);
          },
        ),
        routes: [
          GoRoute(
            path: 'updates',
            builder: (context, state) => const UpdateComposerScreen(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationSenderScreen(),
          ),
          GoRoute(
            path: 'callups',
            builder: (context, state) => const CallupSenderScreen(),
          ),
          GoRoute(
            path: 'matches',
            builder: (context, state) => const MatchEditorScreen(),
          ),
          GoRoute(
            path: 'teams',
            builder: (context, state) => const TeamEditorScreen(),
          ),
          GoRoute(
            path: 'participants',
            builder: (context, state) => const ParticipantManagerScreen(),
          ),
          GoRoute(
            path: 'winners',
            builder: (context, state) => const MatchWinnersScreen(),
          ),
        ],
      ),
    ],
  );
});
