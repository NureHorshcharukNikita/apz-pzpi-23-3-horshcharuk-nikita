import 'package:elevate_mobile/core/router/app_router.dart';
import 'package:elevate_mobile/providers/team/refresh_teams_hub.dart';
import 'package:elevate_mobile/presentation/viewmodels/dashboard/dashboard_viewmodel.dart';
import 'package:elevate_mobile/presentation/viewmodels/profile/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static String _titleForLocation(String matchedLocation) {
    if (matchedLocation.startsWith(AppRoutes.mainTeams)) return 'Teams';
    if (matchedLocation.startsWith(AppRoutes.mainProfile)) return 'Profile';
    return 'Home';
  }

  Future<void> _reloadCurrentBranch(WidgetRef ref, int branchIndex) async {
    switch (branchIndex) {
      case 0:
        await ref.read(dashboardViewModelProvider.notifier).load();
        break;
      case 1:
        await refreshTeamsHub(ref);
        break;
      case 2:
        await ref.read(profileViewModelProvider.notifier).load();
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).matchedLocation;
    final title = _titleForLocation(loc);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(title),
      ),
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (value) async {
          navigationShell.goBranch(value);
          await _reloadCurrentBranch(ref, value);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Teams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
