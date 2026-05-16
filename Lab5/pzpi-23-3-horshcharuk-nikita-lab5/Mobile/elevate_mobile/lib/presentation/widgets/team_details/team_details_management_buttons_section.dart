import 'package:flutter/material.dart';

class TeamDetailsManagementButtonsSection extends StatelessWidget {
  final bool isMember;
  final bool isLead;
  final bool isCreator;
  final Future<void> Function() onPerformAction;
  final VoidCallback onOpenTeamSetup;
  final VoidCallback onLeaveTeam;
  final VoidCallback onDeleteTeam;

  const TeamDetailsManagementButtonsSection({
    super.key,
    required this.isMember,
    required this.isLead,
    required this.isCreator,
    required this.onPerformAction,
    required this.onOpenTeamSetup,
    required this.onLeaveTeam,
    required this.onDeleteTeam,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        if (isMember)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.flash_on),
              label: const Text('Perform Action'),
              onPressed: () async => onPerformAction(),
            ),
          ),
        if (isMember && (isLead || isCreator)) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.tune),
              label: const Text('Team setup (levels & badges)'),
              onPressed: onOpenTeamSetup,
            ),
          ),
        ],
        if (isMember && !isCreator) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Leave team'),
              style: OutlinedButton.styleFrom(
                foregroundColor: scheme.error,
              ),
              onPressed: onLeaveTeam,
            ),
          ),
        ],
        if (isCreator) ...[
          const SizedBox(height: 8),
          Text(
            'As team creator you cannot leave until you delete the team.',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.delete_forever),
              label: const Text('Delete team'),
              style: OutlinedButton.styleFrom(
                foregroundColor: scheme.error,
              ),
              onPressed: onDeleteTeam,
            ),
          ),
        ],
      ],
    );
  }
}
