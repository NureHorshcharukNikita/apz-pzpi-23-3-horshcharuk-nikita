import 'package:elevate_mobile/presentation/widgets/team_details/team_details_stat_card.dart';
import 'package:flutter/material.dart';

class TeamDetailsMemberInsightsSection extends StatelessWidget {
  final Widget? progressCard;
  final String pointsValue;
  final String rankValue;

  const TeamDetailsMemberInsightsSection({
    super.key,
    required this.progressCard,
    required this.pointsValue,
    required this.rankValue,
  });

  @override
  Widget build(BuildContext context) {
    if (progressCard == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        progressCard!,
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TeamDetailsStatCard(
                title: 'Points',
                value: pointsValue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TeamDetailsStatCard(
                title: 'Rank',
                value: rankValue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
