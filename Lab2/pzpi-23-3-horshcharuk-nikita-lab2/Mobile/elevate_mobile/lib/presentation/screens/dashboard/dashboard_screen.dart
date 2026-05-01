import 'package:elevate_mobile/presentation/widgets/dashboard/dashboard_team_block.dart';
import 'package:elevate_mobile/presentation/viewmodels/dashboard/dashboard_viewmodel.dart';
import 'package:elevate_mobile/presentation/widgets/load_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardViewModelProvider);

    return state.when(
      initial: () => const Center(
        child: CircularProgressIndicator(),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (message) => Center(
        child: LoadErrorView(
          message: message,
          onRetry: () =>
              ref.read(dashboardViewModelProvider.notifier).load(),
        ),
      ),
      loaded: (dashboards) {
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(dashboardViewModelProvider.notifier).load(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dashboards.isEmpty)
                  const Text('No teams yet')
                else
                  ...dashboards.expand(
                    (d) => [
                      DashboardTeamBlock(dashboard: d),
                      const SizedBox(height: 24),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
