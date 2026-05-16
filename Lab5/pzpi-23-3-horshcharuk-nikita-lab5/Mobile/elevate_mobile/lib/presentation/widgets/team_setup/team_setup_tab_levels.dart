import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_points_mode.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_threshold.dart';
import 'package:elevate_mobile/presentation/widgets/team_setup/team_setup_tiles.dart';
import 'package:flutter/material.dart';

class TeamSetupLevelsTab extends StatelessWidget {
  final ColorScheme scheme;
  final Team team;
  final List<TeamLevelThreshold> levels;
  final TextEditingController search;
  final VoidCallback onSearchChanged;
  final List<TeamLevelThreshold> Function(List<TeamLevelThreshold>, String)
      filterLevels;
  final void Function(Team team, TeamLevelPointsMode mode)
      onLevelPointsModeChanged;
  final void Function(TeamLevelThreshold) onEditLevel;
  final void Function(TeamLevelThreshold) onDeleteLevel;
  final bool teamBusy;

  const TeamSetupLevelsTab({
    super.key,
    required this.scheme,
    required this.team,
    required this.levels,
    required this.search,
    required this.onSearchChanged,
    required this.filterLevels,
    required this.onLevelPointsModeChanged,
    required this.onEditLevel,
    required this.onDeleteLevel,
    required this.teamBusy,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = filterLevels(levels, search.text);
    final mode = team.levelPointsMode;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      children: [
        TextField(
          controller: search,
          onChanged: (_) => onSearchChanged(),
          decoration: const InputDecoration(
            hintText: 'Search levels',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'How you enter XP',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<TeamLevelPointsMode>(
          segments: const [
            ButtonSegment<TeamLevelPointsMode>(
              value: TeamLevelPointsMode.relativeSegments,
              label: Text('Per level'),
              tooltip: 'Each row = XP for that level only (they add up)',
            ),
            ButtonSegment<TeamLevelPointsMode>(
              value: TeamLevelPointsMode.absoluteTotals,
              label: Text('Total'),
              tooltip: 'Each row = total team XP from zero',
            ),
          ],
          selected: {mode},
          onSelectionChanged: (s) {
            if (teamBusy || s.isEmpty) return;
            onLevelPointsModeChanged(team, s.first);
          },
        ),
        const SizedBox(height: 8),
        Text(
          mode == TeamLevelPointsMode.relativeSegments
              ? 'Per level: enter XP for each step; we store the running total.'
              : 'Total: enter cumulative team XP for each level.',
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Text(
          'Levels (${filtered.length}/${levels.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Gaps in level numbers are filled automatically. Optional notes appear next to a level in the list.',
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        if (levels.isEmpty)
          Text(
            'No levels yet. Tap + to add.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          )
        else if (filtered.isEmpty)
          Text(
            'No matches.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          )
        else
          ...filtered.map(
            (l) => TeamSetupLevelTile(
              level: l,
              levelsSorted: levels,
              pointsMode: mode,
              scheme: scheme,
              onEdit: () => onEditLevel(l),
              onDelete: () => onDeleteLevel(l),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}
