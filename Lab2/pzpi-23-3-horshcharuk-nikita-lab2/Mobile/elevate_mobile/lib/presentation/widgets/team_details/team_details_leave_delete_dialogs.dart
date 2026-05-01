import 'package:flutter/material.dart';

Future<bool> showTeamDetailsLeaveConfirm(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Leave team'),
      content: const Text(
        'You will be removed from this team. Your points, badges, '
        'and activity history for this team will be deleted.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Leave'),
        ),
      ],
    ),
  );
  return ok == true;
}

Future<bool> showTeamDetailsDeleteTeamConfirm(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete team'),
      content: const Text(
        'This will permanently delete the team and all related data '
        '(members, levels, badges, actions). This cannot be undone.',
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
