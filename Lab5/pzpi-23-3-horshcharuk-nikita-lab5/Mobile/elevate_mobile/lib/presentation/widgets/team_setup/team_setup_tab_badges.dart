import 'package:elevate_mobile/domain/entities/team/team_badge_info.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_threshold.dart';
import 'package:elevate_mobile/presentation/widgets/team_setup/team_setup_tiles.dart';
import 'package:flutter/material.dart';

class TeamSetupBadgesTab extends StatelessWidget {
  final ColorScheme scheme;
  final List<TeamLevelThreshold> levels;
  final List<TeamBadgeInfo> badges;
  final TextEditingController search;
  final VoidCallback onSearchChanged;
  final List<TeamBadgeInfo> Function(List<TeamBadgeInfo>, String) filterBadges;
  final void Function(TeamBadgeInfo) onEditBadge;
  final void Function(TeamBadgeInfo) onDeleteBadge;

  const TeamSetupBadgesTab({
    super.key,
    required this.scheme,
    required this.levels,
    required this.badges,
    required this.search,
    required this.onSearchChanged,
    required this.filterBadges,
    required this.onEditBadge,
    required this.onDeleteBadge,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = filterBadges(badges, search.text);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      children: [
        TextField(
          controller: search,
          onChanged: (_) => onSearchChanged(),
          decoration: const InputDecoration(
            hintText: 'Search badges',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Badges (${filtered.length}/${badges.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        if (badges.isEmpty)
          Text(
            'No badges yet. Tap + to add.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          )
        else if (filtered.isEmpty)
          Text(
            'No matches.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          )
        else
          ...filtered.map(
            (b) => TeamSetupBadgeTile(
              badge: b,
              levels: levels,
              scheme: scheme,
              onEdit: () => onEditBadge(b),
              onDelete: () => onDeleteBadge(b),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}
