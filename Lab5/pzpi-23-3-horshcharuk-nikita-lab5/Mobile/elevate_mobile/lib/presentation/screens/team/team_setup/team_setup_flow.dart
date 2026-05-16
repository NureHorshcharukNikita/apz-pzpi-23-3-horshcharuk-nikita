import 'package:elevate_mobile/domain/entities/action/action_type.dart';
import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/domain/entities/team/team_badge_info.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_points_mode.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_threshold.dart';
import 'package:elevate_mobile/presentation/widgets/team_setup/team_setup_add_action_sheet.dart';
import 'package:elevate_mobile/presentation/widgets/team_setup/team_setup_add_badge_sheet.dart';
import 'package:elevate_mobile/presentation/widgets/team_setup/team_setup_add_level_sheet.dart';
import 'package:elevate_mobile/presentation/widgets/team_setup/team_setup_delete_dialogs.dart';
import 'package:elevate_mobile/presentation/widgets/team_setup/team_setup_edit_dialogs.dart';
import 'package:elevate_mobile/presentation/widgets/team_setup/team_setup_feedback.dart';
import 'package:elevate_mobile/presentation/screens/team/team_setup/team_setup_list_helpers.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/team_setup_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamSetupFlow {
  TeamSetupFlow({
    required this.ref,
    required this.teamId,
  });

  final WidgetRef ref;
  final int teamId;

  Future<void> refresh({bool reloadActionTypes = true}) async {
    await ref
        .read(teamSetupViewModelProvider(teamId).notifier)
        .refresh(reloadActionTypes: reloadActionTypes);
  }

  Future<void> saveTeam(
    BuildContext context, {
    required String name,
    required String descriptionTrim,
    required bool unlimitedMembers,
    required String maxMembersText,
  }) async {
    final err = await ref.read(teamSetupViewModelProvider(teamId).notifier).saveTeam(
          name: name,
          descriptionTrim: descriptionTrim,
          unlimitedMembers: unlimitedMembers,
          maxMembersText: maxMembersText,
        );
    if (!context.mounted) return;
    showTeamSetupSnack(context, err ?? 'Team saved');
  }

  Future<void> saveLevelPointsMode(
    BuildContext context,
    Team team,
    TeamLevelPointsMode mode,
  ) async {
    final err = await ref
        .read(teamSetupViewModelProvider(teamId).notifier)
        .saveLevelPointsMode(team, mode);
    if (!context.mounted) return;
    showTeamSetupSnack(
      context,
      err ?? 'XP input mode updated',
    );
  }

  Future<void> showAddLevelSheet(
    BuildContext context,
    TeamLevelPointsMode levelPointsMode,
    List<TeamLevelThreshold> levelsSorted,
  ) async {
    final d = TeamSetupListHelpers.addLevelSheetDefaults(
      levelPointsMode,
      levelsSorted,
    );
    final levelAdded = await showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => TeamSetupAddLevelBottomSheet(
        teamId: teamId,
        levelPointsMode: levelPointsMode,
        levelsSorted: levelsSorted,
        initialOrderText: '${d.order}',
        initialPointsText: d.initialPointsText,
      ),
    );
    if (!context.mounted) return;
    if (levelAdded == true) {
      await refresh(reloadActionTypes: false);
      if (!context.mounted) return;
      showTeamSetupSnack(context, 'Level added');
    }
  }

  Future<void> showAddBadgeSheet(
    BuildContext context,
    List<TeamLevelThreshold> levelsSorted,
  ) async {
    final badgeAdded = await showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => TeamSetupAddBadgeBottomSheet(
        teamId: teamId,
        levelsSorted: levelsSorted,
      ),
    );
    if (!context.mounted) return;
    if (badgeAdded == true) {
      await refresh(reloadActionTypes: false);
      if (!context.mounted) return;
      showTeamSetupSnack(context, 'Badge added');
    }
  }

  Future<void> showAddActionSheet(BuildContext context) async {
    final actionAdded = await showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => TeamSetupAddActionBottomSheet(teamId: teamId),
    );
    if (!context.mounted) return;
    if (actionAdded == true) {
      await refresh();
      if (!context.mounted) return;
      showTeamSetupSnack(context, 'Action type added');
    }
  }

  Future<void> confirmDeleteLevel(
    BuildContext context,
    TeamLevelThreshold level,
  ) async {
    if (!await showTeamSetupDeleteLevelConfirm(context, level)) return;
    if (!context.mounted) return;
    final err = await ref
        .read(teamSetupViewModelProvider(teamId).notifier)
        .deleteTeamLevel(level.id);
    if (!context.mounted) return;
    showTeamSetupSnack(context, err ?? 'Level deleted');
  }

  Future<void> confirmDeleteBadge(
    BuildContext context,
    TeamBadgeInfo badge,
  ) async {
    if (!await showTeamSetupDeleteBadgeConfirm(context, badge)) return;
    if (!context.mounted) return;
    final err = await ref
        .read(teamSetupViewModelProvider(teamId).notifier)
        .deleteTeamBadge(badge.id);
    if (!context.mounted) return;
    showTeamSetupSnack(context, err ?? 'Badge deleted');
  }

  Future<void> confirmDeleteAction(
    BuildContext context,
    ActionType type,
  ) async {
    if (!await showTeamSetupDeleteActionConfirm(context, type)) return;
    if (!context.mounted) return;
    final err = await ref
        .read(teamSetupViewModelProvider(teamId).notifier)
        .deleteActionType(type.id);
    if (!context.mounted) return;
    showTeamSetupSnack(context, err ?? 'Action type deleted');
  }

  Future<void> showEditLevelDialog(
    BuildContext context,
    TeamLevelThreshold level,
    TeamLevelPointsMode levelPointsMode,
    List<TeamLevelThreshold> levelsSorted,
  ) async {
    final ok = await showTeamSetupEditLevelDialog(
      context: context,
      teamId: teamId,
      level: level,
      levelPointsMode: levelPointsMode,
      levelsSorted: levelsSorted,
    );
    if (ok == true && context.mounted) {
      showTeamSetupSnack(context, 'Level updated');
    }
  }

  Future<void> showEditBadgeDialog(
    BuildContext context,
    TeamBadgeInfo badge,
    List<TeamLevelThreshold> levelsSorted,
  ) async {
    final ok = await showTeamSetupEditBadgeDialog(
      context: context,
      teamId: teamId,
      badge: badge,
      levelsSorted: levelsSorted,
    );
    if (ok == true && context.mounted) {
      showTeamSetupSnack(context, 'Badge updated');
    }
  }

  Future<void> showEditActionDialog(
    BuildContext context,
    ActionType type,
  ) async {
    final ok = await showTeamSetupEditActionDialog(
      context: context,
      teamId: teamId,
      type: type,
    );
    if (ok == true && context.mounted) {
      showTeamSetupSnack(context, 'Action type updated');
    }
  }
}
