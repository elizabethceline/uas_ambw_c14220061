import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_scaffold.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/get_started_screen.dart';
import 'screens/features/history_screen.dart';
import 'screens/features/home_screen.dart';
import 'screens/features/stats_screen.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';

class AppRouter {
  final AuthService authService;

  AppRouter(this.authService);

  GoRouter get router => _router;

  late final GoRouter _router = GoRouter(
    refreshListenable: authService,
    initialLocation: '/splash',
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/get-started',
        builder: (context, state) => const GetStartedScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/stats',
                builder: (context, state) => const StatsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) async {
      final loggedIn = authService.isLoggedIn;
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('isFirstTime') ?? true;

      final onSplash = state.matchedLocation == '/splash';
      final onGetStarted = state.matchedLocation == '/get-started';
      final onAuthFlow =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (isFirstTime && !onGetStarted) {
        return '/get-started';
      }

      if (onSplash) {
        return loggedIn ? '/' : '/login';
      }

      if (loggedIn && (onAuthFlow || onGetStarted)) {
        return '/';
      }

      if (!loggedIn && !onAuthFlow && !onGetStarted && !onSplash) {
        return '/login';
      }

      return null;
    },
  );
}
