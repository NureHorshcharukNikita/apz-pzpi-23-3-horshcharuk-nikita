import 'package:elevate_mobile/domain/entities/team/team_level_points_mode.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_threshold.dart';

int prevCumulativeBeforeOrder(
  List<TeamLevelThreshold> sortedAsc,
  int order, {
  int? excludeLevelId,
}) {
  var prev = 0;
  for (final l in sortedAsc) {
    if (excludeLevelId != null && l.id == excludeLevelId) continue;
    if (l.orderIndex < order) {
      prev = l.requiredPoints;
    }
  }
  return prev;
}

int segmentForLevel(
  TeamLevelThreshold level,
  List<TeamLevelThreshold> sortedAsc,
) {
  final prev = prevCumulativeBeforeOrder(
    sortedAsc,
    level.orderIndex,
    excludeLevelId: level.id,
  );
  return level.requiredPoints - prev;
}

int cumulativeFromLevelFormInput({
  required TeamLevelPointsMode mode,
  required int orderIndex,
  required int pointsField,
  required List<TeamLevelThreshold> sortedAsc,
  int? excludeLevelId,
}) {
  final prev = prevCumulativeBeforeOrder(
    sortedAsc,
    orderIndex,
    excludeLevelId: excludeLevelId,
  );
  switch (mode) {
    case TeamLevelPointsMode.relativeSegments:
      return prev + pointsField;
    case TeamLevelPointsMode.absoluteTotals:
      return pointsField;
  }
}
