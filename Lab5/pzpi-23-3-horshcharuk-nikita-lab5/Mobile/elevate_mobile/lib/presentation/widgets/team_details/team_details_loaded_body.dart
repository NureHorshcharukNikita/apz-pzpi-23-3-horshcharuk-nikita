import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/presentation/widgets/team_details/team_details_join_requests_section.dart';
import 'package:elevate_mobile/presentation/widgets/team_details/team_details_join_status_section.dart';
import 'package:elevate_mobile/presentation/widgets/team_details/team_details_management_buttons_section.dart';
import 'package:elevate_mobile/presentation/widgets/team_details/team_details_member_insights_section.dart';
import 'package:elevate_mobile/presentation/widgets/team_details/team_details_members_section.dart';
import 'package:elevate_mobile/presentation/widgets/team_details/team_details_summary_section.dart';
import 'package:elevate_mobile/presentation/states/team/team_members_state.dart';
import 'package:flutter/material.dart';

class TeamDetailsLoadedBody extends StatelessWidget {
  final Team team;
  final int teamId;
  final ColorScheme scheme;
  final ThemeData theme;
  final TeamMembersState membersState;
  final int? myUserId;
  final Widget? progressCard;
  final String insightsPoints;
  final String insightsRank;
  final bool showPendingJoinBanner;
  final bool canOfferJoin;
  final bool hasPendingJoinRequest;
  final bool isMember;
  final bool isLead;
  final bool isCreator;
  final bool canManageMemberProgress;
  final bool canManageJoin;
  final Future<void> Function() onPullRefresh;
  final VoidCallback onCancelJoinRequest;
  final VoidCallback onJoinTeam;
  final Future<void> Function() onPerformAction;
  final VoidCallback onOpenTeamSetup;
  final VoidCallback onLeaveTeam;
  final VoidCallback onDeleteTeam;

  const TeamDetailsLoadedBody({
    super.key,
    required this.team,
    required this.teamId,
    required this.scheme,
    required this.theme,
    required this.membersState,
    required this.myUserId,
    required this.progressCard,
    required this.insightsPoints,
    required this.insightsRank,
    required this.showPendingJoinBanner,
    required this.canOfferJoin,
    required this.hasPendingJoinRequest,
    required this.isMember,
    required this.isLead,
    required this.isCreator,
    required this.canManageMemberProgress,
    required this.canManageJoin,
    required this.onPullRefresh,
    required this.onCancelJoinRequest,
    required this.onJoinTeam,
    required this.onPerformAction,
    required this.onOpenTeamSetup,
    required this.onLeaveTeam,
    required this.onDeleteTeam,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onPullRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          TeamDetailsSummarySection(team: team, scheme: scheme),
          TeamDetailsMemberInsightsSection(
            progressCard: progressCard,
            pointsValue: insightsPoints,
            rankValue: insightsRank,
          ),
          TeamDetailsJoinStatusSection(
            showPendingJoinBanner: showPendingJoinBanner,
            onCancelJoinRequest: onCancelJoinRequest,
            canOfferJoin: canOfferJoin,
            hasPendingJoinRequest: hasPendingJoinRequest,
            team: team,
            scheme: scheme,
            theme: theme,
            onJoinTeam: onJoinTeam,
          ),
          TeamDetailsManagementButtonsSection(
            isMember: isMember,
            isLead: isLead,
            isCreator: isCreator,
            onPerformAction: onPerformAction,
            onOpenTeamSetup: onOpenTeamSetup,
            onLeaveTeam: onLeaveTeam,
            onDeleteTeam: onDeleteTeam,
          ),
          if (canManageJoin) ...[
            const SizedBox(height: 24),
            const Text(
              'Join requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TeamDetailsJoinRequestsSection(teamId: teamId),
          ],
          TeamDetailsMembersSection(
            teamId: teamId,
            team: team,
            membersState: membersState,
            myUserId: myUserId,
            isCreator: isCreator,
            canManageMemberProgress: canManageMemberProgress,
          ),
        ],
      ),
    );
  }
}
