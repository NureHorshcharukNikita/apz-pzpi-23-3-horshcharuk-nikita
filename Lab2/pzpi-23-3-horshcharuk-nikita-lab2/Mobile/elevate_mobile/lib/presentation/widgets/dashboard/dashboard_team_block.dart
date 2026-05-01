import 'package:elevate_mobile/domain/entities/dashboard/dashboard.dart';
import 'package:elevate_mobile/presentation/widgets/common/stat_value_card.dart';
import 'package:flutter/material.dart';

class DashboardTeamBlock extends StatelessWidget {
  final Dashboard dashboard;

  const DashboardTeamBlock({
    super.key,
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    final progress = dashboard.nextLevelXp == 0
        ? 0.0
        : (dashboard.currentXp / dashboard.nextLevelXp).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dashboard.teamName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level ${dashboard.level}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                ),
                const SizedBox(height: 8),
                Text(
                  '${dashboard.currentXp} / ${dashboard.nextLevelXp} XP',
                ),
              ],
            ),
          ),
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
            const SizedBox(width: 8),
            Expanded(
              child: StatValueCard(
                title: 'Rank',
                value: '#${dashboard.rank}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Recent achievements',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        ...dashboard.recentAchievements.map(
          (e) => Card(
            child: ListTile(
              leading: const Icon(
                Icons.emoji_events,
              ),
              title: Text(e),
            ),
          ),
        ),
      ],
    );
  }
}
