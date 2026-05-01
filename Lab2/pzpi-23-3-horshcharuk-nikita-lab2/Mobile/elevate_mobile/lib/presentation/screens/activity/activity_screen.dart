import 'package:elevate_mobile/presentation/widgets/activity/activity_feed_tile.dart';
import 'package:elevate_mobile/presentation/viewmodels/activity/activity_viewmodel.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/my_teams_viewmodel.dart';
import 'package:elevate_mobile/presentation/widgets/load_error_view.dart';
import 'package:elevate_mobile/presentation/widgets/team_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activityViewModelProvider);
    final teamsState = ref.watch(myTeamsViewModelProvider);
    final filterTeamId =
        ref.read(activityViewModelProvider.notifier).filterTeamId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: teamsState.maybeWhen(
              loaded: (teams) => TeamFilterDropdown(
                teams: teams,
                selectedTeamId: filterTeamId,
                onChanged: (id) => ref
                    .read(activityViewModelProvider.notifier)
                    .setFilterTeamId(id),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ),
          Expanded(
            child: state.when(
              initial: () => const Center(
                child: CircularProgressIndicator(),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e) => Center(
                child: LoadErrorView(
                  message: e,
                  onRetry: () =>
                      ref.read(activityViewModelProvider.notifier).load(),
                ),
              ),
              loaded: (activity) {
                if (activity.isEmpty) {
                  return Center(
                    child: Text(
                      filterTeamId == null
                          ? 'No activity yet'
                          : 'No activity for this team',
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(activityViewModelProvider.notifier)
                      .load(),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: activity.length,
                    itemBuilder: (context, index) {
                      return ActivityFeedTile(item: activity[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
