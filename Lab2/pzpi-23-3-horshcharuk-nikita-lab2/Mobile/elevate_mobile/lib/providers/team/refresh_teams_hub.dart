import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elevate_mobile/presentation/viewmodels/dashboard/dashboard_viewmodel.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/my_teams_viewmodel.dart';
import 'package:elevate_mobile/providers/team/team_provider.dart';

Future<void> refreshTeamsHub(WidgetRef ref) async {
  ref.invalidate(myPendingJoinRequestsProvider);
  await Future.wait<void>([
    ref.read(myTeamsViewModelProvider.notifier).load(
          showLoadingIndicator: false,
        ),
    ref.read(discoverTeamsProvider.notifier).refresh(),
    ref.read(dashboardViewModelProvider.notifier).load(
          showLoadingIndicator: false,
        ),
  ]);
}
