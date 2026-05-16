import 'package:elevate_mobile/domain/entities/team/team_level_threshold.dart';

abstract final class TeamBadgeCondition {
  static const totalPoints = 'TotalPoints';
  static const levelOrder = 'LevelOrder';
}

bool teamBadgeConditionIsLevelOrder(String? t) {
  if (t == null || t.isEmpty) return false;
  final x = t.toLowerCase();
  return x == 'levelorder' || x == 'teamlevel';
}

bool teamBadgeConditionIsPoints(String? t) {
  if (t == null || t.isEmpty) return false;
  final x = t.toLowerCase();
  return x == 'totalpoints' ||
      x == 'pointsreached' ||
      x == 'points' ||
      x == 'xp';
}

String teamBadgeConditionSummary({
  required String? conditionType,
  required int? conditionValue,
  required List<TeamLevelThreshold> levels,
}) {
  if (conditionType == null ||
      conditionType.isEmpty ||
      conditionValue == null) {
    return 'No award rule (never unlocks)';
  }
  if (teamBadgeConditionIsPoints(conditionType)) {
    return 'Team XP ≥ $conditionValue';
  }
  if (teamBadgeConditionIsLevelOrder(conditionType)) {
    for (final l in levels) {
      if (l.orderIndex == conditionValue) {
        final note = l.name.trim().isEmpty ? '' : ' · ${l.name.trim()}';
        return 'Level $conditionValue$note';
      }
    }
    return 'Level order ≥ $conditionValue';
  }
  return '$conditionType $conditionValue';
}
