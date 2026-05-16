import 'package:elevate_mobile/domain/entities/action/action_type.dart';
import 'package:elevate_mobile/domain/entities/team/team_badge_info.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_threshold.dart';
import 'package:flutter/material.dart';

Future<bool> showTeamSetupDeleteLevelConfirm(
  BuildContext context,
  TeamLevelThreshold level,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete level?'),
      content: Text(
        'Remove ${level.displayTitle} (level ${level.orderIndex})? '
        'Progress will use the remaining levels.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return ok == true;
}

Future<bool> showTeamSetupDeleteBadgeConfirm(
  BuildContext context,
  TeamBadgeInfo badge,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete badge?'),
      content: Text(
        'Remove "${badge.name}" (${badge.code})? Awards will be removed.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return ok == true;
}

Future<bool> showTeamSetupDeleteActionConfirm(
  BuildContext context,
  ActionType type,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete action type?'),
      content: Text(
        'Remove "${type.name}"? This is only allowed if no actions have been logged for it.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return ok == true;
}
