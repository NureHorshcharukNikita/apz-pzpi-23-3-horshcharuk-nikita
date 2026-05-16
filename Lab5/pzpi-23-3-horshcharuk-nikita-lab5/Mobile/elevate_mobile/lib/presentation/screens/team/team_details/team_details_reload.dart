import 'package:elevate_mobile/providers/team/refresh_teams_hub.dart';
import 'package:elevate_mobile/presentation/viewmodels/dashboard/dashboard_viewmodel.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/team_details_viewmodel.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/team_members_viewmodel.dart';
import 'package:elevate_mobile/providers/team/team_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void teamDetailsOnRouteOpened(WidgetRef ref, int teamId) {
  ref.read(teamMembersViewModelProvider(teamId).notifier).load(
        showLoadingIndicator: true,
      );
  ref.read(teamDetailsViewModelProvider(teamId).notifier).load(
        showLoadingIndicator: false,
      );
  ref.invalidate(myPendingJoinRequestsProvider);
  ref.read(dashboardViewModelProvider.notifier).load(
        showLoadingIndicator: false,
      );
}

Future<void> teamDetailsPullRefresh(WidgetRef ref, int teamId) async {
  await Future.wait<void>([
    ref
        .read(teamDetailsViewModelProvider(teamId).notifier)
        .load(showLoadingIndicator: false),
    ref
        .read(teamMembersViewModelProvider(teamId).notifier)
        .load(showLoadingIndicator: false),
    refreshTeamsHub(ref),
  ]);
  ref.invalidate(teamJoinRequestsProvider(teamId));
}
