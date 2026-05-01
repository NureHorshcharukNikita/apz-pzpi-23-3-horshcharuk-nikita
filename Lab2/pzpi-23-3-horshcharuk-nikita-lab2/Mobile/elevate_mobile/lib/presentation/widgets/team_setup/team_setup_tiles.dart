import 'package:elevate_mobile/domain/entities/action/action_type.dart';
import 'package:elevate_mobile/domain/entities/team/team_badge_info.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_points_mode.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_threshold.dart';
import 'package:elevate_mobile/core/utils/team_badge_condition.dart';
import 'package:elevate_mobile/core/utils/team_level_points_input.dart';
import 'package:flutter/material.dart';

class TeamSetupLevelTile extends StatelessWidget {
  final TeamLevelThreshold level;
  final List<TeamLevelThreshold> levelsSorted;
  final TeamLevelPointsMode pointsMode;
  final ColorScheme scheme;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TeamSetupLevelTile({
    super.key,
    required this.level,
    required this.levelsSorted,
    required this.pointsMode,
    required this.scheme,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final seg = segmentForLevel(level, levelsSorted);
    final xpLine = pointsMode == TeamLevelPointsMode.relativeSegments
        ? '+$seg this level · ${level.requiredPoints} stored total'
        : '${level.requiredPoints} total XP';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: scheme.primaryContainer,
              child: Text(
                '${level.orderIndex}',
                style: TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level ${level.orderIndex}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (level.name.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      level.name.trim(),
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    xpLine,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: 'Delete',
              icon: Icon(Icons.delete_outline, color: scheme.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class TeamSetupBadgeTile extends StatelessWidget {
  final TeamBadgeInfo badge;
  final List<TeamLevelThreshold> levels;
  final ColorScheme scheme;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TeamSetupBadgeTile({
    super.key,
    required this.badge,
    required this.levels,
    required this.scheme,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final conditionLine = teamBadgeConditionSummary(
      conditionType: badge.conditionType,
      conditionValue: badge.conditionValue,
      levels: levels,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    badge.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge.code,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEdit,
                ),
                IconButton(
                  tooltip: 'Delete',
                  icon: Icon(Icons.delete_outline, color: scheme.error),
                  onPressed: onDelete,
                ),
              ],
            ),
            if (badge.description != null &&
                badge.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                badge.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              'Unlock: $conditionLine',
              style: TextStyle(fontSize: 13, color: scheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class TeamSetupActionTypeTile extends StatelessWidget {
  final ActionType type;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TeamSetupActionTypeTile({
    super.key,
    required this.type,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.code,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (type.description != null &&
                      type.description!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        type.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${type.defaultPoints} pts',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: scheme.primary,
                  ),
                ),
                if (type.category != null && type.category!.isNotEmpty)
                  Text(
                    type.category!,
                    style: TextStyle(fontSize: 12, color: scheme.outline),
                  ),
                if (!type.isActive)
                  Text(
                    'inactive',
                    style: TextStyle(fontSize: 12, color: scheme.error),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: Icon(Icons.delete_outline, color: scheme.error),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
