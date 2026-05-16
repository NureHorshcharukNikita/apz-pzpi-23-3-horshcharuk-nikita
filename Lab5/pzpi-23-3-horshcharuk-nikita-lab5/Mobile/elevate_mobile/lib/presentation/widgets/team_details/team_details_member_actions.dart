import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:elevate_mobile/domain/entities/team/team_member.dart';
import 'package:elevate_mobile/providers/team/refresh_teams_hub.dart';
import 'package:elevate_mobile/presentation/viewmodels/dashboard/dashboard_viewmodel.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/team_details_viewmodel.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/team_members_viewmodel.dart';
import 'package:elevate_mobile/providers/team/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> teamDetailsEditMemberTeamPoints(
  BuildContext context,
  WidgetRef ref,
  int teamId,
  TeamMember member,
) async {
  final controller = TextEditingController(text: '${member.points}');
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Team points — ${member.name}'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Points',
          hintText: '0 or more',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  final parsed = int.tryParse(controller.text.trim());
  if (parsed == null || parsed < 0) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enter a valid non-negative number.')),
    );
    return;
  }
  try {
    await ref
        .read(teamRepositoryProvider)
        .setMemberTeamPoints(teamId, member.id, parsed);
    await Future.wait<void>([
      ref.read(teamMembersViewModelProvider(teamId).notifier).load(
            showLoadingIndicator: false,
          ),
      ref.read(dashboardViewModelProvider.notifier).load(
            showLoadingIndicator: false,
          ),
      ref.read(teamDetailsViewModelProvider(teamId).notifier).load(
            showLoadingIndicator: false,
          ),
    ]);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Points updated')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapError(e))),
      );
    }
  }
}

Future<void> teamDetailsConfirmRemoveMember(
  BuildContext context,
  WidgetRef ref,
  int teamId,
  TeamMember member,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Remove member'),
      content: Text(
        'Remove ${member.name} from this team? Their points, badges, '
        'and activity for this team will be deleted.',
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
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  try {
    await ref.read(kickTeamMemberUseCaseProvider).call(teamId, member.id);
    await Future.wait<void>([
      ref.read(teamMembersViewModelProvider(teamId).notifier).load(
            showLoadingIndicator: false,
          ),
      ref.read(teamDetailsViewModelProvider(teamId).notifier).load(
            showLoadingIndicator: false,
          ),
      refreshTeamsHub(ref),
    ]);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member removed')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapError(e))),
      );
    }
  }
}
