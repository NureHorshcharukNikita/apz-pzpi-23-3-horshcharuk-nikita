import 'package:elevate_mobile/domain/entities/action/action_type.dart';
import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/domain/entities/team/team_badge_info.dart';
import 'package:elevate_mobile/presentation/screens/team/team_setup/team_setup_flow.dart';
import 'package:elevate_mobile/presentation/screens/team/team_setup/team_setup_list_helpers.dart';
import 'package:elevate_mobile/presentation/widgets/team_setup/team_setup_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamSetupTabStack extends StatelessWidget {
  final TabController tabController;
  final Team team;
  final int teamId;
  final ColorScheme scheme;
  final bool teamBusy;
  final AsyncValue<List<ActionType>> actionTypesAsync;
  final TextEditingController teamName;
  final TextEditingController teamDesc;
  final TextEditingController teamMaxMembers;
  final TextEditingController searchLevels;
  final TextEditingController searchBadges;
  final TextEditingController searchActions;
  final bool unlimitedMembers;
  final ValueChanged<bool>? onUnlimitedMembersChanged;
  final VoidCallback bumpSearch;
  final TeamSetupFlow flow;

  const TeamSetupTabStack({
    super.key,
    required this.tabController,
    required this.team,
    required this.teamId,
    required this.scheme,
    required this.teamBusy,
    required this.actionTypesAsync,
    required this.teamName,
    required this.teamDesc,
    required this.teamMaxMembers,
    required this.searchLevels,
    required this.searchBadges,
    required this.searchActions,
    required this.unlimitedMembers,
    required this.onUnlimitedMembersChanged,
    required this.bumpSearch,
    required this.flow,
  });

  @override
  Widget build(BuildContext context) {
    final levels = TeamSetupListHelpers.sortedLevels(team.levelThresholds);
    final badges = team.badges ?? const <TeamBadgeInfo>[];

    return TabBarView(
      controller: tabController,
      children: [
        RefreshIndicator(
          onRefresh: () => flow.refresh(),
          child: TeamSetupTeamInfoTab(
            teamName: teamName,
            teamDesc: teamDesc,
            teamMaxMembers: teamMaxMembers,
            unlimitedMembers: unlimitedMembers,
            onUnlimitedMembersChanged: onUnlimitedMembersChanged,
            busy: teamBusy,
            onSave: () => flow.saveTeam(
              context,
              name: teamName.text,
              descriptionTrim: teamDesc.text.trim(),
              unlimitedMembers: unlimitedMembers,
              maxMembersText: teamMaxMembers.text,
            ),
          ),
        ),
        RefreshIndicator(
          onRefresh: () => flow.refresh(),
          child: TeamSetupLevelsTab(
            scheme: scheme,
            team: team,
            levels: levels,
            search: searchLevels,
            onSearchChanged: bumpSearch,
            filterLevels: TeamSetupListHelpers.filterLevels,
            onLevelPointsModeChanged: (t, m) =>
                flow.saveLevelPointsMode(context, t, m),
            onEditLevel: (l) => flow.showEditLevelDialog(
              context,
              l,
              team.levelPointsMode,
              levels,
            ),
            onDeleteLevel: (l) => flow.confirmDeleteLevel(context, l),
            teamBusy: teamBusy,
          ),
        ),
        RefreshIndicator(
          onRefresh: () => flow.refresh(),
          child: TeamSetupBadgesTab(
            scheme: scheme,
            levels: levels,
            badges: badges,
            search: searchBadges,
            onSearchChanged: bumpSearch,
            filterBadges: TeamSetupListHelpers.filterBadges,
            onEditBadge: (b) => flow.showEditBadgeDialog(context, b, levels),
            onDeleteBadge: (b) => flow.confirmDeleteBadge(context, b),
          ),
        ),
        RefreshIndicator(
          onRefresh: () => flow.refresh(),
          child: TeamSetupActionsTab(
            teamId: teamId,
            scheme: scheme,
            actionTypesAsync: actionTypesAsync,
            search: searchActions,
            onSearchChanged: bumpSearch,
            filterActionTypes: TeamSetupListHelpers.filterActionTypes,
            onEditAction: (t) => flow.showEditActionDialog(context, t),
            onDeleteAction: (t) => flow.confirmDeleteAction(context, t),
          ),
        ),
      ],
    );
  }
}
