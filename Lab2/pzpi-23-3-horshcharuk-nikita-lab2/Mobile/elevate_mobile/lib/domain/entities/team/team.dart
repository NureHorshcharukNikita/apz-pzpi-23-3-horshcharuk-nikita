import 'package:elevate_mobile/domain/entities/team/team_badge_info.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_points_mode.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_threshold.dart';

class Team {
  final int id;
  final String name;
  final String? description;
  final int? level;
  final String? tierName;
  final int? points;
  final List<TeamLevelThreshold>? levelThresholds;

  final int? createdByUserId;

  final List<TeamBadgeInfo>? badges;

  final TeamLevelPointsMode levelPointsMode;

  final int memberCount;

  final int? maxMembers;

  const Team({
    required this.id,
    required this.name,
    this.description,
    this.level,
    this.tierName,
    this.points,
    this.levelThresholds,
    this.createdByUserId,
    this.badges,
    this.levelPointsMode = TeamLevelPointsMode.absoluteTotals,
    this.memberCount = 0,
    this.maxMembers,
  });

  bool get hasMemberLimit => maxMembers != null;

  bool get isTeamFull =>
      maxMembers != null && memberCount >= maxMembers!;

  int? get spotsRemaining {
    final cap = maxMembers;
    if (cap == null) return null;
    final left = cap - memberCount;
    return left < 0 ? 0 : left;
  }
}