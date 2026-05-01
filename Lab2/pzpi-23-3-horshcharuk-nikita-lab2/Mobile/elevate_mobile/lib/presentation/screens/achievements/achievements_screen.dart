import 'package:elevate_mobile/presentation/widgets/achievements/achievement_list_tile.dart';
import 'package:elevate_mobile/presentation/viewmodels/achievements/achievements_viewmodel.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/my_teams_viewmodel.dart';
import 'package:elevate_mobile/presentation/widgets/load_error_view.dart';
import 'package:elevate_mobile/presentation/widgets/team_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(achievementsViewModelProvider);
    final teamsState = ref.watch(myTeamsViewModelProvider);
    final filterTeamId =
        ref.read(achievementsViewModelProvider.notifier).filterTeamId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
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
                    .read(achievementsViewModelProvider.notifier)
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
                  onRetry: () => ref
                      .read(achievementsViewModelProvider.notifier)
                      .load(),
                ),
              ),
              loaded: (achievements) {
                if (achievements.isEmpty) {
                  return Center(
                    child: Text(
                      filterTeamId == null
                          ? 'No achievements yet'
                          : 'No achievements for this team',
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(achievementsViewModelProvider.notifier)
                      .load(),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: achievements.length,
                    itemBuilder: (context, index) {
                      return AchievementListTile(
                        achievement: achievements[index],
                      );
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
