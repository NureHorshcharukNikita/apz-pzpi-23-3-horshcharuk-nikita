import 'package:elevate_mobile/domain/entities/dashboard/dashboard.dart';
import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/domain/entities/team/team_member.dart';
import 'package:elevate_mobile/presentation/widgets/team_details/team_details_progress_helpers.dart';
import 'package:elevate_mobile/presentation/states/dashboard/dashboard_state.dart';
import 'package:elevate_mobile/presentation/states/team/team_members_state.dart';
import 'package:elevate_mobile/presentation/widgets/team_level_progress_card.dart';
import 'package:flutter/material.dart';

TeamMember? teamDetailsFindMeInTeam(
  TeamMembersState membersState,
  int? myUserId,
) {
  return membersState.maybeWhen(
    loaded: (members) {
      if (myUserId == null) return null;
      for (final m in members) {
        if (m.id == myUserId) return m;
      }
      return null;
    },
    orElse: () => null,
  );
}

Dashboard? teamDetailsDashboardForTeam(
  DashboardState dashState,
  int teamId,
) {
  return dashState.maybeWhen(
    loaded: (list) {
      for (final d in list) {
        if (d.teamId == teamId) return d;
      }
      return null;
    },
    orElse: () => null,
  );
}

Widget? teamDetailsBuildMyProgressCard({
  required bool isMember,
  required Dashboard? teamDash,
  required TeamMember? meInTeam,
  required Team team,
}) {
  if (!isMember || (teamDash == null && meInTeam == null)) return null;
  final points = teamDash?.points ?? meInTeam!.points;
  final prog = teamDetailsProgressFromTeamLevels(team, points);
  final String? myTierName = teamDetailsResolveMyTierName(
    team,
    teamDash: teamDash,
    meInTeam: meInTeam,
  );
  return TeamLevelProgressCard(
    level: prog.level,
    currentXp: prog.currentXp,
    nextLevelXp: prog.nextLevelXp,
    badgeName: myTierName ?? prog.tierName,
    nextMilestoneTotal: prog.nextMilestoneTotal,
    atMaxTier: prog.atMaxTier,
  );
}

({String points, String rank}) teamDetailsInsightsStatLines({
  required Widget? progressCard,
  required Dashboard? teamDash,
  required TeamMember? meInTeam,
}) {
  if (progressCard == null) {
    return (points: '', rank: '');
  }
  return (
    points: teamDash != null ? '${teamDash.points}' : '${meInTeam!.points}',
    rank: teamDash != null ? '#${teamDash.rank}' : '—',
  );
}
