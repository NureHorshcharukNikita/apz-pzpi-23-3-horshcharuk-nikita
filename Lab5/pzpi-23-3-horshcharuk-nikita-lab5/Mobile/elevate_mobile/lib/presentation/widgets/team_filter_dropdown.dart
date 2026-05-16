import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:flutter/material.dart';

class TeamFilterDropdown extends StatelessWidget {
  final List<Team> teams;
  final int? selectedTeamId;
  final ValueChanged<int?> onChanged;

  const TeamFilterDropdown({
    super.key,
    required this.teams,
    required this.selectedTeamId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Team',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          isExpanded: true,
          value: _safeValue(teams, selectedTeamId),
          hint: const Text('All teams'),
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Text(
                'All teams',
                style: TextStyle(color: scheme.onSurface),
              ),
            ),
            ...teams.map(
              (t) => DropdownMenuItem<int?>(
                value: t.id,
                child: Text(t.name),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  int? _safeValue(List<Team> teams, int? selected) {
    if (selected == null) return null;
    final ok = teams.any((t) => t.id == selected);
    return ok ? selected : null;
  }
}
