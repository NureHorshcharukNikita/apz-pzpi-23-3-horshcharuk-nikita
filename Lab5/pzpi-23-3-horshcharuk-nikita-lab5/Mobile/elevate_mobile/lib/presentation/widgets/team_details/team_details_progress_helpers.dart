import 'package:elevate_mobile/domain/entities/dashboard/dashboard.dart';
import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_threshold.dart';
import 'package:elevate_mobile/domain/entities/team/team_member.dart';
import 'package:elevate_mobile/core/utils/team_level_progress.dart';

({
  int level,
  int currentXp,
  int nextLevelXp,
  String? tierName,
  int? nextMilestoneTotal,
  bool atMaxTier,
}) teamDetailsProgressFromTeamLevels(Team team, int memberPoints) {
  final th = team.levelThresholds ?? <TeamLevelThreshold>[];
  return computeTeamLevelProgress(memberPoints, th);
}

String? teamDetailsResolveMyTierName(
  Team team, {
  Dashboard? teamDash,
  TeamMember? meInTeam,
}) {
  final thresholds = team.levelThresholds;
  final points = teamDash?.points ?? meInTeam?.points;
  if (points != null && thresholds != null && thresholds.isNotEmpty) {
    final c = computeTeamLevelProgress(points, thresholds);
    final tn = c.tierName?.trim();
    if (tn != null && tn.isNotEmpty) return tn;
  }
  final api = teamDash?.tierName ?? meInTeam?.tierName;
  final t = api?.trim();
  if (t != null && t.isNotEmpty) return t;
  return null;
}

String teamDetailsMemberSubtitle(int level, String? tierName) {
  final tier =
      (tierName != null && tierName.isNotEmpty) ? tierName : null;
  if (tier != null) return 'Level $level · $tier';
  return 'Level $level';
}
