import 'package:flutter/material.dart';

class TeamLevelProgressCard extends StatelessWidget {
  final int level;
  final int currentXp;
  final int nextLevelXp;
  final String? badgeName;

  final int? nextMilestoneTotal;

  final bool atMaxTier;

  const TeamLevelProgressCard({
    super.key,
    required this.level,
    required this.currentXp,
    required this.nextLevelXp,
    this.badgeName,
    this.nextMilestoneTotal,
    this.atMaxTier = false,
  });

  @override
  Widget build(BuildContext context) {
    final double progress;
    if (atMaxTier) {
      progress = 1.0;
    } else if (nextLevelXp <= 0) {
      progress = 0.0;
    } else {
      progress = currentXp / nextLevelXp;
    }

    final scheme = Theme.of(context).colorScheme;
    final tier = badgeName?.trim();
    final hasTier = tier != null && tier.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Level $level',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (hasTier)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.military_tech,
                        size: 22,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tier,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
            const SizedBox(height: 8),
            Text(
              atMaxTier
                  ? 'Highest tier · +$currentXp XP beyond last milestone'
                  : '$currentXp / $nextLevelXp XP in this tier',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (nextMilestoneTotal != null) ...[
              const SizedBox(height: 4),
              Text(
                'Next milestone: $nextMilestoneTotal cumulative team XP '
                '(the fraction above is only XP left in this tier)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
