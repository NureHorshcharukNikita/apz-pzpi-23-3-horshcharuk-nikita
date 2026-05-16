import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/core/router/app_router.dart';
import 'package:elevate_mobile/presentation/screens/team/team_screen/team_screen_helpers.dart';
import 'package:elevate_mobile/presentation/widgets/team_screen/team_screen_my_teams_widgets.dart';
import 'package:elevate_mobile/providers/team/refresh_teams_hub.dart';
import 'package:elevate_mobile/presentation/viewmodels/dashboard/dashboard_viewmodel.dart';
import 'package:elevate_mobile/presentation/viewmodels/profile/profile_viewmodel.dart';
import 'package:elevate_mobile/presentation/widgets/load_error_view.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/my_teams_viewmodel.dart';
import 'package:elevate_mobile/providers/team/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TeamMyTeamsTab extends ConsumerStatefulWidget {
  const TeamMyTeamsTab({super.key});

  @override
  ConsumerState<TeamMyTeamsTab> createState() => _TeamMyTeamsTabState();
}

class _TeamMyTeamsTabState extends ConsumerState<TeamMyTeamsTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myTeamsViewModelProvider);
    final pendingAsync = ref.watch(myPendingJoinRequestsProvider);
    final profileState = ref.watch(profileViewModelProvider);
    final dashState = ref.watch(dashboardViewModelProvider);
    final dashboards = dashState.maybeWhen(
      loaded: (list) => list,
      orElse: () => null,
    );

    final int? myUserId = profileState.maybeWhen(
      loaded: (u) => u.userID,
      orElse: () => null,
    );

    return state.when(
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
              ref.read(myTeamsViewModelProvider.notifier).load(),
        ),
      ),
      loaded: (teams) {
        final pendingList = pendingAsync.valueOrNull ?? [];
        final q = _searchController.text.trim().toLowerCase();
        final teamsFiltered = filterMyTeamsByQuery(teams, q);
        final pendingFiltered = filterMyPendingByQuery(pendingList, q);

        final List<Team> createdTeams;
        final List<Team> joinedTeams;
        if (myUserId != null) {
          createdTeams = teamsFiltered
              .where((t) => t.createdByUserId == myUserId)
              .toList();
          joinedTeams = teamsFiltered
              .where((t) => t.createdByUserId != myUserId)
              .toList();
        } else {
          createdTeams = [];
          joinedTeams = teamsFiltered;
        }

        final hasSearch = q.isNotEmpty;
        final nothingMatchesSearch = hasSearch &&
            createdTeams.isEmpty &&
            joinedTeams.isEmpty &&
            pendingFiltered.isEmpty &&
            !pendingAsync.isLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search team...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.wait<void>([
                    refreshTeamsHub(ref),
                    ref.read(profileViewModelProvider.notifier).load(),
                  ]);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.add_circle_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: const Text('Create a team'),
                        subtitle: const Text(
                          'You’ll be the lead and can add levels and badges',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.push(AppRoutes.teamCreate);
                        },
                      ),
                    ),
                    if (teams.isEmpty &&
                        pendingList.isEmpty &&
                        !pendingAsync.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No teams yet — create one above, or use '
                            'Discover to find a team to join.',
                          ),
                        ),
                      )
                    else if (nothingMatchesSearch)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text('No teams match your search'),
                        ),
                      )
                    else if (myUserId == null)
                      ...teamsFiltered.map(
                        (team) => TeamMyTeamRowCard(
                          team: team,
                          dash: findDashboardForTeam(dashboards, team.id),
                        ),
                      )
                    else ...[
                      const TeamMyTeamsSectionHeader(title: 'Teams I created'),
                      if (createdTeams.isEmpty)
                        TeamMyTeamsSectionEmpty(
                          message: hasSearch
                              ? 'No matching teams in this section.'
                              : 'No teams created yet.',
                        )
                      else
                        ...createdTeams.map(
                          (team) => TeamMyTeamRowCard(
                            team: team,
                            dash: findDashboardForTeam(dashboards, team.id),
                          ),
                        ),
                      const TeamMyTeamsSectionHeader(title: 'Teams I joined'),
                      if (joinedTeams.isEmpty)
                        TeamMyTeamsSectionEmpty(
                          message: hasSearch
                              ? 'No matching teams in this section.'
                              : 'Not a member of any other teams yet.',
                        )
                      else
                        ...joinedTeams.map(
                          (team) => TeamMyTeamRowCard(
                            team: team,
                            dash: findDashboardForTeam(dashboards, team.id),
                          ),
                        ),
                      const TeamMyTeamsSectionHeader(
                        title: 'Pending applications',
                      ),
                      if (pendingAsync.isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      else if (pendingAsync.hasError)
                        const TeamMyTeamsSectionEmpty(
                          message:
                              'Could not load pending requests. Pull to retry.',
                        )
                      else if (pendingFiltered.isEmpty)
                        TeamMyTeamsSectionEmpty(
                          message: hasSearch
                              ? 'No matching pending requests.'
                              : 'No pending join requests.',
                        )
                      else
                        ...pendingFiltered.map(
                          (r) => TeamPendingApplicationRowCard(request: r),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
