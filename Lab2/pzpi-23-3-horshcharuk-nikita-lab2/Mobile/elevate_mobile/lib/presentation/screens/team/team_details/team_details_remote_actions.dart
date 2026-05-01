import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:elevate_mobile/core/router/app_router.dart';
import 'package:elevate_mobile/presentation/widgets/team_details/team_details_leave_delete_dialogs.dart';
import 'package:elevate_mobile/providers/team/refresh_teams_hub.dart';
import 'package:elevate_mobile/presentation/viewmodels/dashboard/dashboard_viewmodel.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/team_details_viewmodel.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/team_members_viewmodel.dart';
import 'package:elevate_mobile/providers/team/selected_team_provider.dart';
import 'package:elevate_mobile/providers/team/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Future<void> teamDetailsJoinFlow(BuildContext context, WidgetRef ref, int teamId) async {
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
  }
}

Future<void> teamDetailsCancelJoinFlow(BuildContext context, WidgetRef ref, int teamId) async {
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
  }
}

Future<void> teamDetailsLeaveTeamFlow(BuildContext context, WidgetRef ref, int teamId) async {
  if (!await showTeamDetailsLeaveConfirm(context)) return;
  if (!context.mounted) return;

  try {
    await ref.read(leaveTeamUseCaseProvider).call(teamId);
    await ref.read(selectedTeamIdProvider.notifier).clearIfMatches(teamId);
    await refreshTeamsHub(ref);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Left team')),
      );
      context.pop();
    }
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mapError(e))),
    );
  }
}

Future<void> teamDetailsDeleteTeamFlow(BuildContext context, WidgetRef ref, int teamId) async {
  if (!await showTeamDetailsDeleteTeamConfirm(context)) return;
  if (!context.mounted) return;

  try {
    await ref.read(deleteTeamUseCaseProvider).call(teamId);
    await ref.read(selectedTeamIdProvider.notifier).clearIfMatches(teamId);
    await refreshTeamsHub(ref);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Team deleted')),
    );
    context.pop();
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mapError(e))),
    );
  }
}

Future<void> teamDetailsAfterPerformAction(
  BuildContext context,
  WidgetRef ref,
  int screenTeamId,
  int teamNumericId,
) async {
  await context.push<void>(
    AppRoutes.teamActionsById(teamNumericId),
  );
  if (!context.mounted) return;
  await Future.wait<void>([
    ref.read(dashboardViewModelProvider.notifier).load(
          showLoadingIndicator: false,
        ),
    ref
        .read(teamMembersViewModelProvider(screenTeamId).notifier)
        .load(showLoadingIndicator: false),
    ref
        .read(teamDetailsViewModelProvider(screenTeamId).notifier)
        .load(showLoadingIndicator: false),
  ]);
}
