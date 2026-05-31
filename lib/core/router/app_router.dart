import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/navigation_shell.dart';

// Import all module screens
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

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return NavigationShell(navigationShell: navigationShell);
      },
      branches: [
        // 0: Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        // 1: Office Work
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/office',
              builder: (context, state) => const OfficeScreen(),
            ),
          ],
        ),
        // 2: Freelance
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/freelance',
              builder: (context, state) => const FreelanceScreen(),
            ),
          ],
        ),
        // 3: Completed Work
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/completed',
              builder: (context, state) => const CompletedScreen(),
            ),
          ],
        ),
        // 4: Tasks
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tasks',
              builder: (context, state) => const TasksScreen(),
            ),
          ],
        ),
        // 5: Projects
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/projects',
              builder: (context, state) => const ProjectsScreen(),
            ),
          ],
        ),
        // 6: Calendar
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const CalendarScreen(),
            ),
          ],
        ),
        // 7: Notes
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notes',
              builder: (context, state) => const NotesScreen(),
            ),
          ],
        ),
        // 8: Finance
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/finance',
              builder: (context, state) => const FinanceScreen(),
            ),
          ],
        ),
        // 9: Developer Workspace
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dev',
              builder: (context, state) => const DevWorkspaceScreen(),
            ),
          ],
        ),
        // 10: Goals & Habits
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/goals',
              builder: (context, state) => const GoalsScreen(),
            ),
          ],
        ),
        // 11: Learning & Career
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/learning',
              builder: (context, state) => const LearningScreen(),
            ),
          ],
        ),
        // 12: Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
