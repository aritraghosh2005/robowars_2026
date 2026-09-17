import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/core/auth/auth_providers.dart';
import 'package:robowars_app/features/shell/views/main_layout.dart';
import 'package:robowars_app/features/splash/views/splash_screen.dart';
import 'package:robowars_app/features/auth/views/auth_screen.dart';
import 'package:robowars_app/features/admin/views/admin_dashboard_screen.dart';
import 'package:robowars_app/features/admin/views/match_editor_screen.dart';
import 'package:robowars_app/features/admin/views/team_editor_screen.dart';
import 'package:robowars_app/features/admin/views/match_winners_screen.dart';
import 'package:robowars_app/features/admin/views/notification_sender_screen.dart';
import 'package:robowars_app/features/admin/views/callup_sender_screen.dart';
import 'package:robowars_app/features/admin/views/update_composer_screen.dart';
import 'package:robowars_app/features/admin/auth/admin_service.dart';
import 'package:robowars_app/services/service_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final roleServiceState = ref.watch(roleServiceProvider);
  // Watch auth state so the router re-evaluates on login / logout.
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      // While auth is still loading, do nothing.
      if (authState.isLoading) return null;

      final user = authState.asData?.value;
      final onAuthPage = state.matchedLocation == '/auth';

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
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainLayout(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
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
            path: 'winners',
            builder: (context, state) => const MatchWinnersScreen(),
          ),
        ],
      ),
    ],
  );
});
