import 'package:elevate_mobile/core/utils/date_format_ua.dart';
import 'package:elevate_mobile/domain/entities/achievement/achievement.dart';
import 'package:flutter/material.dart';

class AchievementSubtitle extends StatelessWidget {
  final Achievement achievement;

  const AchievementSubtitle({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = achievement;

    if (!a.earned) {
      return const Text('Locked');
    }

    final parts = <String>[
      if (a.teamName != null && a.teamName!.isNotEmpty)
        'Team: ${a.teamName}',
      if (a.earnedAt != null) formatDateUa(a.earnedAt!),
    ];
    final line1 = parts.isEmpty ? 'Earned' : parts.join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(line1),
        if (a.requirement != null && a.requirement!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              a.requirement!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (a.description.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              a.description,
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
