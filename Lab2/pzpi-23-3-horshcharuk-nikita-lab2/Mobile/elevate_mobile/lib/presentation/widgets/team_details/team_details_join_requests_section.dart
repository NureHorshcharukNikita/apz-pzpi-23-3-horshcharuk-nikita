import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:elevate_mobile/core/utils/date_format_ua.dart';
import 'package:elevate_mobile/providers/team/refresh_teams_hub.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/team_details_viewmodel.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/team_members_viewmodel.dart';
import 'package:elevate_mobile/presentation/widgets/load_error_view.dart';
import 'package:elevate_mobile/providers/team/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamDetailsJoinRequestsSection extends ConsumerWidget {
  final int teamId;

  const TeamDetailsJoinRequestsSection({super.key, required this.teamId});

  Future<void> _approve(
    BuildContext context,
    WidgetRef ref,
    int requestId,
  ) async {
    try {
      await ref
          .read(approveJoinRequestUseCaseProvider)
          .call(teamId, requestId);
      ref.invalidate(teamJoinRequestsProvider(teamId));
      await Future.wait<void>([
        ref.read(teamMembersViewModelProvider(teamId).notifier).load(
              showLoadingIndicator: false,
            ),
        ref.read(teamDetailsViewModelProvider(teamId).notifier).load(
              showLoadingIndicator: false,
            ),
        refreshTeamsHub(ref),
      ]);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Join request approved')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapError(e))),
      );
    }
  }

  Future<void> _reject(
    BuildContext context,
    WidgetRef ref,
    int requestId,
  ) async {
    try {
      await ref
          .read(rejectJoinRequestUseCaseProvider)
          .call(teamId, requestId);
      ref.invalidate(teamJoinRequestsProvider(teamId));
      await refreshTeamsHub(ref);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Join request rejected')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapError(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(teamJoinRequestsProvider(teamId));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => LoadErrorView.fromError(
        e,
        compact: true,
        onRetry: () =>
            ref.invalidate(teamJoinRequestsProvider(teamId)),
      ),
      data: (requests) {
        final pending = requests
            .where((r) => r.status.toLowerCase() == 'pending')
            .toList();
        if (pending.isEmpty) {
          return Text(
            'No pending requests',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        }
        return Column(
          children: pending.map((r) {
            final dateStr = formatDateUa(r.requestedAt);
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      r.userFullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Requested $dateStr',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _reject(context, ref, r.id),
                            child: const Text('Reject'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => _approve(context, ref, r.id),
                            child: const Text('Approve'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
