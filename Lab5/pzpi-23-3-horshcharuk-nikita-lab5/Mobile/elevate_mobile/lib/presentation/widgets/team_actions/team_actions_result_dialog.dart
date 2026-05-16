import 'package:elevate_mobile/domain/entities/action/action_result.dart';
import 'package:elevate_mobile/presentation/screens/team/team_actions/team_actions_helpers.dart';
import 'package:elevate_mobile/presentation/viewmodels/actions/actions_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showTeamActionCompletedDialog(
  BuildContext context,
  WidgetRef ref,
  int teamId,
  ActionResult result,
) {
  final levelLabel = (result.newTeamLevelName ?? '').trim();
  final badges = result.newBadges;

  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Action completed'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Points: +${result.pointsAwarded}'),
          Text('Total points: ${result.totalTeamPoints}'),
          if (levelLabel.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'New level: ${compactActionLevelLabel(levelLabel)}',
              ),
            ),
          if (badges.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'New badge${badges.length > 1 ? 's' : ''}: '
                '${badges.join(', ')}',
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            ref.read(actionsViewModelProvider(teamId).notifier).clearResult();
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
