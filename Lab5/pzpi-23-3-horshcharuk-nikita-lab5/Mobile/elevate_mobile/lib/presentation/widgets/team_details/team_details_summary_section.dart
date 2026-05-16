import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:flutter/material.dart';

class TeamDetailsSummarySection extends StatelessWidget {
  final Team team;
  final ColorScheme scheme;

  const TeamDetailsSummarySection({
    super.key,
    required this.team,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          team.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(team.description ?? 'No description'),
        if (team.hasMemberLimit) ...[
          const SizedBox(height: 8),
          Text(
            team.isTeamFull
                ? 'Team is full (${team.memberCount}/${team.maxMembers} members).'
                : '${team.memberCount}/${team.maxMembers} members · '
                    '${team.spotsRemaining} spot(s) open',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ] else if (team.memberCount > 0) ...[
          const SizedBox(height: 8),
          Text(
            '${team.memberCount} members (no member limit)',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}
