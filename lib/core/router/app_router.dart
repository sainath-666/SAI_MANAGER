import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/navigation_shell.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/office/presentation/screens/office_screen.dart';
import '../../features/freelance/presentation/screens/freelance_screen.dart';
import '../../features/completed/presentation/screens/completed_screen.dart';
import '../../features/tasks/presentation/screens/tasks_screen.dart';
import '../../features/projects/presentation/screens/projects_screen.dart';
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/notes/presentation/screens/notes_screen.dart';
import '../../features/finance/presentation/screens/finance_screen.dart';
import '../../features/dev/presentation/screens/dev_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/learning/presentation/screens/learning_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      if (!auth.isInitialized) return null;

      final loggedIn = auth.isAuthenticated;
      final onLogin = state.matchedLocation == '/login';

      if (!loggedIn && !onLogin) return '/login';
      if (loggedIn && onLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', builder: (c, s) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/office', builder: (c, s) => const OfficeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/freelance',
                builder: (c, s) => const FreelanceScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/completed',
                builder: (c, s) => const CompletedScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/tasks', builder: (c, s) => const TasksScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/projects',
                builder: (c, s) => const ProjectsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/calendar',
                builder: (c, s) => const CalendarScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/notes', builder: (c, s) => const NotesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/finance',
                builder: (c, s) => const FinanceScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/dev',
                builder: (c, s) => const DevWorkspaceScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/goals', builder: (c, s) => const GoalsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/learning',
                builder: (c, s) => const LearningScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/settings',
                builder: (c, s) => const SettingsScreen()),
          ]),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    notifier.dispose();
  });

  return router;
});
