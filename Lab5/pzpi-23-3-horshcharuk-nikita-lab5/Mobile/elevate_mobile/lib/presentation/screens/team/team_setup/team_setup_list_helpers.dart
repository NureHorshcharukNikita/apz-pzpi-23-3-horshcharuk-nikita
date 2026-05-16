import 'package:elevate_mobile/domain/entities/action/action_type.dart';
import 'package:elevate_mobile/domain/entities/team/team_badge_info.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_points_mode.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_threshold.dart';
import 'package:elevate_mobile/core/utils/team_level_points_input.dart';

class TeamSetupListHelpers {
  TeamSetupListHelpers._();

  static List<TeamLevelThreshold> sortedLevels(List<TeamLevelThreshold>? raw) {
    final list = List<TeamLevelThreshold>.from(raw ?? const []);
    list.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return list;
  }

  static int nextLevelOrder(List<TeamLevelThreshold> levels) {
    if (levels.isEmpty) return 1;
    var max = levels.first.orderIndex;
    for (final l in levels) {
      if (l.orderIndex > max) max = l.orderIndex;
    }
    return max + 1;
  }

  static ({int order, String initialPointsText}) addLevelSheetDefaults(
    TeamLevelPointsMode levelPointsMode,
    List<TeamLevelThreshold> levelsSorted,
  ) {
    final suggested = nextLevelOrder(levelsSorted);
    final prevForSuggested =
        prevCumulativeBeforeOrder(levelsSorted, suggested);
    final defaultPts = levelPointsMode == TeamLevelPointsMode.relativeSegments
        ? (suggested <= 1 ? '400' : '100')
        : (prevForSuggested + (suggested <= 1 ? 400 : 100)).toString();
    return (order: suggested, initialPointsText: defaultPts);
  }

  static bool matches(String query, String text) {
    if (query.trim().isEmpty) return true;
    return text.toLowerCase().contains(query.trim().toLowerCase());
  }

  static List<TeamLevelThreshold> filterLevels(
    List<TeamLevelThreshold> levels,
    String q,
  ) {
    return levels
        .where(
          (l) =>
              matches(q, l.name) ||
              matches(q, '${l.orderIndex}') ||
              matches(q, '${l.requiredPoints}'),
        )
        .toList();
  }

  static List<TeamBadgeInfo> filterBadges(
    List<TeamBadgeInfo> badges,
    String q,
  ) {
    return badges
        .where(
          (b) =>
              matches(q, b.name) ||
              matches(q, b.code) ||
              matches(q, b.description ?? ''),
        )
        .toList();
  }

  static List<ActionType> filterActionTypes(
    List<ActionType> types,
    String q,
  ) {
    return types
        .where(
          (t) =>
              matches(q, t.name) ||
              matches(q, t.code) ||
              matches(q, t.description ?? ''),
        )
        .toList();
  }
}
