import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:flutter/material.dart';

class TeamDetailsJoinStatusSection extends StatelessWidget {
  final bool showPendingJoinBanner;
  final VoidCallback onCancelJoinRequest;
  final bool canOfferJoin;
  final bool hasPendingJoinRequest;
  final Team team;
  final ColorScheme scheme;
  final ThemeData theme;
  final VoidCallback onJoinTeam;

  const TeamDetailsJoinStatusSection({
    super.key,
    required this.showPendingJoinBanner,
    required this.onCancelJoinRequest,
    required this.canOfferJoin,
    required this.hasPendingJoinRequest,
    required this.team,
    required this.scheme,
    required this.theme,
    required this.onJoinTeam,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showPendingJoinBanner) ...[
          const SizedBox(height: 16),
          Material(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.hourglass_top,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your join request is waiting for a team '
                          'lead to approve.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onCancelJoinRequest,
                      child: const Text('Cancel request'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (canOfferJoin && !hasPendingJoinRequest) ...[
          const SizedBox(height: 16),
          if (team.isTeamFull)
            Material(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.group_off, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This team is full (${team.memberCount}/'
                        '${team.maxMembers}).',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.group_add),
                label: const Text('Join team'),
                onPressed: onJoinTeam,
              ),
            ),
        ],
      ],
    );
  }
}
