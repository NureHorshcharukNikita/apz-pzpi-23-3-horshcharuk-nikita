import 'package:elevate_mobile/presentation/widgets/home/home_dashboard_section.dart';
import 'package:elevate_mobile/presentation/widgets/home/home_empty_teams_card.dart';
import 'package:elevate_mobile/presentation/widgets/home/home_team_dropdown.dart';
import 'package:elevate_mobile/presentation/viewmodels/dashboard/dashboard_viewmodel.dart';
import 'package:elevate_mobile/presentation/widgets/load_error_view.dart';
import 'package:elevate_mobile/presentation/widgets/team_selection_helpers.dart';
import 'package:elevate_mobile/providers/team/selected_team_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardViewModelProvider);
    final selectedTeamId = ref.watch(selectedTeamIdProvider);

    ref.listen(dashboardViewModelProvider, (previous, next) {
      next.maybeWhen(
        loaded: (dashboards) {
          ref
              .read(selectedTeamIdProvider.notifier)
              .ensureValidSelection(dashboards);
        },
        orElse: () {},
      );
    });

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
        if (dashboards.isEmpty) {
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(dashboardViewModelProvider.notifier).load(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: const [HomeEmptyTeamsCard()],
            ),
          );
        }

        final effectiveId =
            effectiveTeamIdForDashboards(dashboards, selectedTeamId);
        final current = dashboardForSelection(dashboards, selectedTeamId);

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(dashboardViewModelProvider.notifier).load(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              HomeTeamDropdown(
                effectiveId: effectiveId,
                dashboards: dashboards,
                onChanged: (id) {
                  ref.read(selectedTeamIdProvider.notifier).setTeamId(id);
                },
              ),
              const SizedBox(height: 16),
              if (current != null) HomeDashboardSection(dashboard: current),
            ],
          ),
        );
      },
    );
  }
}
