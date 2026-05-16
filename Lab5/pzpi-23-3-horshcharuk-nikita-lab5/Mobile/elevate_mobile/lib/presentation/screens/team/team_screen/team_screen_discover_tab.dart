import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:elevate_mobile/core/router/app_router.dart';
import 'package:elevate_mobile/presentation/widgets/team_screen/team_discover_search_header.dart';
import 'package:elevate_mobile/presentation/widgets/team_screen/team_discover_team_card.dart';
import 'package:elevate_mobile/presentation/widgets/team_screen/team_discover_team_trailing.dart';
import 'package:elevate_mobile/presentation/screens/team/team_screen/team_screen_helpers.dart';
import 'package:elevate_mobile/presentation/states/team/my_teams_state.dart';
import 'package:elevate_mobile/providers/team/refresh_teams_hub.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/my_teams_viewmodel.dart';
import 'package:elevate_mobile/presentation/widgets/load_error_view.dart';
import 'package:elevate_mobile/providers/team/team_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TeamDiscoverTeamsTab extends ConsumerStatefulWidget {
  const TeamDiscoverTeamsTab({super.key});

  @override
  ConsumerState<TeamDiscoverTeamsTab> createState() =>
      _TeamDiscoverTeamsTabState();
}

class _TeamDiscoverTeamsTabState extends ConsumerState<TeamDiscoverTeamsTab> {
  final searchController = TextEditingController();
  final Set<int> _joiningTeamIds = {};
  final Set<int> _cancellingTeamIds = {};

  Set<int>? _myTeamIdsCache;
  TeamDiscoverShowFilter _showTeams = TeamDiscoverShowFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(myTeamsViewModelProvider).maybeWhen(
            loaded: (teams) {
              setState(() {
                _myTeamIdsCache = teams.map((t) => t.id).toSet();
              });
            },
            error: (_) {
              setState(() => _myTeamIdsCache = {});
            },
            orElse: () {},
          );
    });
  }

  Future<void> _joinTeam(BuildContext context, int teamId) async {
    if (_joiningTeamIds.contains(teamId)) return;
    setState(() => _joiningTeamIds.add(teamId));
    try {
      await ref.read(joinTeamUseCaseProvider).call(teamId);
      await refreshTeamsHub(ref);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Request sent. A team lead will review your join request.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapError(e))),
      );
    } finally {
      if (mounted) {
        setState(() => _joiningTeamIds.remove(teamId));
      }
    }
  }

  Future<void> _cancelJoinRequest(BuildContext context, int teamId) async {
    if (_cancellingTeamIds.contains(teamId)) return;
    setState(() => _cancellingTeamIds.add(teamId));
    try {
      await ref.read(cancelMyJoinRequestUseCaseProvider).call(teamId);
      await refreshTeamsHub(ref);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Join request cancelled')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapError(e))),
      );
    } finally {
      if (mounted) {
        setState(() => _cancellingTeamIds.remove(teamId));
      }
    }
  }

  Future<void> _onRefreshDiscover() async {
    await refreshTeamsHub(ref);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoverTeamsProvider);
    final pendingAsync = ref.watch(myPendingJoinRequestsProvider);
    ref.watch(myTeamsViewModelProvider);

    ref.listen<MyTeamsState>(myTeamsViewModelProvider, (previous, next) {
      next.maybeWhen(
        loaded: (teams) {
          final ids = teams.map((t) => t.id).toSet();
          if (_myTeamIdsCache == null || !setEquals(_myTeamIdsCache, ids)) {
            setState(() => _myTeamIdsCache = ids);
          }
        },
        error: (_) {
          if (_myTeamIdsCache == null) {
            setState(() => _myTeamIdsCache = {});
          }
        },
        orElse: () {},
      );
    });

    final membershipReady = _myTeamIdsCache != null;
    final myTeamIds = _myTeamIdsCache ?? {};
    final pendingTeamIds = pendingAsync.maybeWhen(
      data: (list) => list.map((r) => r.teamId).toSet(),
      orElse: () => <int>{},
    );

    return Column(
      children: [
        TeamDiscoverSearchField(
          controller: searchController,
          onSearchChanged: (value) {
            ref.read(discoverTeamsProvider.notifier).search(value);
          },
        ),
        TeamDiscoverShowFilterBar(
          value: _showTeams,
          onChanged: (v) => setState(() => _showTeams = v),
        ),
        Expanded(
          child: state.when(
            loading: () => RefreshIndicator(
              onRefresh: _onRefreshDiscover,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 48),
                children: const [
                  Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
            error: (e, _) => RefreshIndicator(
              onRefresh: _onRefreshDiscover,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                children: [
                  LoadErrorView.fromError(
                    e,
                    onRetry: () {
                      _onRefreshDiscover();
                    },
                  ),
                ],
              ),
            ),
            data: (teams) {
              if (teams.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _onRefreshDiscover,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 48),
                    children: const [
                      Center(child: Text('No teams found')),
                    ],
                  ),
                );
              }

              final visible = _showTeams == TeamDiscoverShowFilter.openSpots
                  ? teams.where((t) => !t.isTeamFull).toList()
                  : teams;

              if (visible.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _onRefreshDiscover,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 48),
                    children: const [
                      Center(
                        child: Text(
                          'No teams with open spots match your search',
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _onRefreshDiscover,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final team = visible[index];
                    return TeamDiscoverTeamCard(
                      team: team,
                      onTapDetails: () async {
                        await context.push<void>(
                          AppRoutes.teamDetailsById(team.id),
                        );
                        if (context.mounted) {
                          await refreshTeamsHub(ref);
                        }
                      },
                      trailing: TeamDiscoverTeamTrailing(
                        team: team,
                        membershipReady: membershipReady,
                        myTeamIds: myTeamIds,
                        pendingTeamIds: pendingTeamIds,
                        joining: _joiningTeamIds.contains(team.id),
                        cancelling: _cancellingTeamIds.contains(team.id),
                        onOpenTeamDetails: () async {
                          await context.push<void>(
                            AppRoutes.teamDetailsById(team.id),
                          );
                          if (context.mounted) {
                            await refreshTeamsHub(ref);
                          }
                        },
                        onJoin: () => _joinTeam(context, team.id),
                        onCancelPending: () =>
                            _cancelJoinRequest(context, team.id),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
