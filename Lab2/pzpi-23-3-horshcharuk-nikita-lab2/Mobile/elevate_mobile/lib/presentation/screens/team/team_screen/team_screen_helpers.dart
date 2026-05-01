import 'package:elevate_mobile/domain/entities/dashboard/dashboard.dart';
import 'package:elevate_mobile/domain/entities/team/my_pending_join_request.dart';
import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/core/utils/team_level_progress.dart';

enum TeamDiscoverShowFilter { all, openSpots }

String discoverTeamMemberCapacityLine(Team t) {
  if (!t.hasMemberLimit) {
    return '${t.memberCount} members · no limit';
  }
  if (t.isTeamFull) {
    return '${t.memberCount}/${t.maxMembers} · full';
  }
  final left = t.spotsRemaining ?? 0;
  return '${t.memberCount}/${t.maxMembers} · $left open';
}

List<Team> filterMyTeamsByQuery(List<Team> teams, String q) {
  if (q.isEmpty) return teams;
  return teams.where((t) {
    if (t.name.toLowerCase().contains(q)) return true;
    final desc = t.description?.toLowerCase() ?? '';
    return desc.contains(q);
  }).toList();
}

List<MyPendingJoinRequest> filterMyPendingByQuery(
  List<MyPendingJoinRequest> list,
  String q,
) {
  if (q.isEmpty) return list;
  return list
      .where((r) => r.teamName.toLowerCase().contains(q))
      .toList();
}

Dashboard? findDashboardForTeam(List<Dashboard>? list, int teamId) {
  if (list == null) return null;
  for (final d in list) {
    if (d.teamId == teamId) return d;
  }
  return null;
}

({int? level, String? tierName}) myTeamRowProgressForList(
  Team team,
  Dashboard? dash,
) {
  if (dash != null) {
    return (
      level: dash.level,
      tierName: dash.tierName ?? team.tierName,
    );
  }

  final thresholds = team.levelThresholds;
  final points = team.points;
  if (points != null && thresholds != null && thresholds.isNotEmpty) {
    final c = computeTeamLevelProgress(points, thresholds);
    return (
      level: c.level,
      tierName: c.tierName ?? team.tierName,
    );
  }

  return (level: team.level, tierName: team.tierName);
}
