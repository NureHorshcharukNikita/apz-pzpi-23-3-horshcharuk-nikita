import 'package:elevate_mobile/presentation/widgets/team_details/team_details_loaded_body.dart';
import 'package:elevate_mobile/presentation/screens/team/team_details/team_details_reload.dart';
import 'package:elevate_mobile/presentation/screens/team/team_details/team_details_remote_actions.dart';
import 'package:elevate_mobile/presentation/screens/team/team_details/team_details_view_helpers.dart';
import 'package:elevate_mobile/presentation/viewmodels/dashboard/dashboard_viewmodel.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/team_details_viewmodel.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/team_members_viewmodel.dart';
import 'package:elevate_mobile/presentation/widgets/load_error_view.dart';
import 'package:elevate_mobile/providers/auth/auth_preferences_provider.dart';
import 'package:elevate_mobile/providers/team/team_provider.dart';
import 'package:elevate_mobile/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TeamDetailsScreen extends ConsumerStatefulWidget {
  final int teamId;

  const TeamDetailsScreen({
    super.key,
    required this.teamId,
  });

  @override
  ConsumerState<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState extends ConsumerState<TeamDetailsScreen>
    with WidgetsBindingObserver {
  late final DateTime _openedAt;

  @override
  void initState() {
    super.initState();
    _openedAt = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) teamDetailsOnRouteOpened(ref, widget.teamId);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (DateTime.now().difference(_openedAt) < const Duration(seconds: 1)) {
      return;
    }
    _silentRefresh();
  }

  Future<void> _silentRefresh() async {
    if (!mounted) return;
    await teamDetailsPullRefresh(ref, widget.teamId);
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.teamId;
    final state = ref.watch(teamDetailsViewModelProvider(id));
    final membersState = ref.watch(teamMembersViewModelProvider(id));
    final dashState = ref.watch(dashboardViewModelProvider);
    final pendingAsync = ref.watch(myPendingJoinRequestsProvider);
    final myUserId = ref.watch(authPreferencesProvider).getUserId();

    final membersLoaded = membersState.maybeWhen(
      loaded: (_) => true,
      orElse: () => false,
    );

    final hasPendingJoinRequest = pendingAsync.maybeWhen(
      data: (list) => list.any((r) => r.teamId == id),
      orElse: () => false,
    );

    final isMember = membersState.maybeWhen(
      loaded: (members) =>
          myUserId != null && members.any((m) => m.id == myUserId),
      orElse: () => false,
    );

    final showPendingJoinBanner = myUserId != null &&
        membersLoaded &&
        hasPendingJoinRequest &&
        !isMember;

    final canOfferJoin = membersState.maybeWhen(
      loaded: (members) =>
          myUserId != null && !members.any((m) => m.id == myUserId),
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Details'),
      ),
      body: state.when(
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
                .read(teamDetailsViewModelProvider(id).notifier)
                .load(),
          ),
        ),
        loaded: (team) {
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;
          final meInTeam = teamDetailsFindMeInTeam(membersState, myUserId);
          final isLead = meInTeam != null &&
              meInTeam.teamRole.toLowerCase() == 'lead';
          final isCreator = myUserId != null &&
              team.createdByUserId != null &&
              team.createdByUserId == myUserId;
          final canManageMemberProgress = isMember && (isLead || isCreator);
          final canManageJoin = isLead || (isCreator && isMember);
          final teamDash = teamDetailsDashboardForTeam(dashState, id);

          final myProgress = teamDetailsBuildMyProgressCard(
            isMember: isMember,
            teamDash: teamDash,
            meInTeam: meInTeam,
            team: team,
          );
          final insights = teamDetailsInsightsStatLines(
            progressCard: myProgress,
            teamDash: teamDash,
            meInTeam: meInTeam,
          );

          return TeamDetailsLoadedBody(
            team: team,
            teamId: id,
            scheme: scheme,
            theme: theme,
            membersState: membersState,
            myUserId: myUserId,
            progressCard: myProgress,
            insightsPoints: insights.points,
            insightsRank: insights.rank,
            showPendingJoinBanner: showPendingJoinBanner,
            canOfferJoin: canOfferJoin,
            hasPendingJoinRequest: hasPendingJoinRequest,
            isMember: isMember,
            isLead: isLead,
            isCreator: isCreator,
            canManageMemberProgress: canManageMemberProgress,
            canManageJoin: canManageJoin,
            onPullRefresh: () => teamDetailsPullRefresh(ref, id),
            onCancelJoinRequest: () =>
                teamDetailsCancelJoinFlow(context, ref, id),
            onJoinTeam: () => teamDetailsJoinFlow(context, ref, id),
            onPerformAction: () => teamDetailsAfterPerformAction(
              context,
              ref,
              id,
              team.id,
            ),
            onOpenTeamSetup: () {
              context.push<void>(
                AppRoutes.teamSetupById(team.id),
              );
            },
            onLeaveTeam: () => teamDetailsLeaveTeamFlow(context, ref, id),
            onDeleteTeam: () => teamDetailsDeleteTeamFlow(context, ref, id),
          );
        },
      ),
    );
  }
}
