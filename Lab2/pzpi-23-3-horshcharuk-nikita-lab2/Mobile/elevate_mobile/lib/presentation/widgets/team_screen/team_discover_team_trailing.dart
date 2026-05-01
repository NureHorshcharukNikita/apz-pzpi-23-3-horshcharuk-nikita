import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:flutter/material.dart';

class TeamDiscoverTeamTrailing extends StatelessWidget {
  final Team team;
  final bool membershipReady;
  final Set<int> myTeamIds;
  final Set<int> pendingTeamIds;
  final bool joining;
  final bool cancelling;
  final Future<void> Function() onOpenTeamDetails;
  final VoidCallback onJoin;
  final VoidCallback onCancelPending;

  const TeamDiscoverTeamTrailing({
    super.key,
    required this.team,
    required this.membershipReady,
    required this.myTeamIds,
    required this.pendingTeamIds,
    required this.joining,
    required this.cancelling,
    required this.onOpenTeamDetails,
    required this.onJoin,
    required this.onCancelPending,
  });

  @override
  Widget build(BuildContext context) {
    if (!membershipReady) {
      return const SizedBox(
        width: 88,
        height: 40,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final alreadyMember = myTeamIds.contains(team.id);
    final pending = pendingTeamIds.contains(team.id);

    if (alreadyMember) {
      return OutlinedButton(
        onPressed: () async => onOpenTeamDetails(),
        child: const Text('Open'),
      );
    }
    if (pending) {
      final scheme = Theme.of(context).colorScheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pending',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          OutlinedButton(
            onPressed: cancelling ? null : onCancelPending,
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: cancelling
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.primary,
                    ),
                  )
                : const Text('Cancel'),
          ),
        ],
      );
    }
    if (joining) {
      return const SizedBox(
        width: 28,
        height: 28,
        child: Padding(
          padding: EdgeInsets.all(4),
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }
    if (team.isTeamFull) {
      return OutlinedButton(
        onPressed: null,
        child: Text(
          'Full',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return ElevatedButton(
      onPressed: onJoin,
      child: const Text('Join'),
    );
  }
}
