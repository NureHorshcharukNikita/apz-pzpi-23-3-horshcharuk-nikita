import 'package:elevate_mobile/domain/entities/dashboard/dashboard.dart';
import 'package:elevate_mobile/presentation/widgets/common/stat_value_card.dart';
import 'package:elevate_mobile/presentation/widgets/team_level_progress_card.dart';
import 'package:flutter/material.dart';

class HomeDashboardSection extends StatelessWidget {
  final Dashboard dashboard;

  const HomeDashboardSection({
    super.key,
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dashboard.teamName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TeamLevelProgressCard(
          level: dashboard.level,
          currentXp: dashboard.currentXp,
          nextLevelXp: dashboard.nextLevelXp,
          badgeName: dashboard.tierName,
          atMaxTier: dashboard.atMaxTier,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatValueCard(
                title: 'Points',
                value: dashboard.points.toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatValueCard(
                title: 'Rank',
                value: '#${dashboard.rank}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Recent achievements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (dashboard.recentAchievements.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No achievements yet'),
            ),
          )
        else
          ...dashboard.recentAchievements.map(
            (achievement) => Card(
              child: ListTile(
                leading: const Icon(Icons.emoji_events),
                title: Text(achievement),
              ),
            ),
          ),
      ],
    );
  }
}
