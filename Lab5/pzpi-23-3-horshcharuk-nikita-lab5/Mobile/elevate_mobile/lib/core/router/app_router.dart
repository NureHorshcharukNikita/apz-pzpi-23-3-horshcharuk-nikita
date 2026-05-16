import 'package:elevate_mobile/presentation/screens/activity/activity_screen.dart';
import 'package:elevate_mobile/presentation/screens/achievements/achievements_screen.dart';
import 'package:elevate_mobile/presentation/screens/auth/login_screen.dart';
import 'package:elevate_mobile/presentation/screens/auth/register_screen.dart';
import 'package:elevate_mobile/presentation/screens/home/home_screen.dart';
import 'package:elevate_mobile/presentation/screens/main_shell_screen.dart';
import 'package:elevate_mobile/presentation/screens/profile/edit_profile_screen.dart';
import 'package:elevate_mobile/presentation/screens/profile/profile_screen.dart';
import 'package:elevate_mobile/presentation/screens/splash/splash_screen.dart';
import 'package:elevate_mobile/presentation/screens/team/create_team_screen.dart';
import 'package:elevate_mobile/presentation/screens/team/team_actions_screen.dart';
import 'package:elevate_mobile/presentation/screens/team/team_details_screen.dart';
import 'package:elevate_mobile/presentation/screens/team/team_screen.dart';
import 'package:elevate_mobile/presentation/screens/team/team_setup_screen.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';

  static const main = '/main';
  static const mainHome = '/main/home';
  static const mainTeams = '/main/teams';
  static const mainProfile = '/main/profile';

  static const team = '/team';
  static const teamDetails = '/team/:id';
  static const teamActions = '/team/:id/actions';
  static const teamCreate = '/team/create';
  static const teamSetup = '/team/:id/setup';

  static const achievements = '/achievements';
  static const activity = '/activity';

  static const editProfile = '/profile/edit';

  static String teamDetailsById(int id) => '/team/$id';
  static String teamActionsById(int id) => '/team/$id/actions';
  static String teamSetupById(int id) => '/team/$id/setup';
}

String? _globalRedirect(BuildContext context, GoRouterState state) {
  final path = state.uri.path;
  if (path == AppRoutes.main) {
    return AppRoutes.mainHome;
  }
  return null;
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  redirect: _globalRedirect,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.team,
      redirect: (context, state) => AppRoutes.mainTeams,
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.mainHome,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.mainTeams,
              builder: (context, state) => const TeamScreen(
                showScaffold: false,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.mainProfile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.teamCreate,
      builder: (context, state) => const CreateTeamScreen(),
    ),
    GoRoute(
      path: AppRoutes.teamDetails,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return TeamDetailsScreen(teamId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.teamSetup,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return TeamSetupScreen(teamId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.achievements,
      builder: (context, state) => const AchievementsScreen(),
    ),
    GoRoute(
      path: AppRoutes.activity,
      builder: (context, state) => const ActivityScreen(),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.teamActions,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return TeamActionsScreen(teamId: id);
      },
    ),
  ],
);
