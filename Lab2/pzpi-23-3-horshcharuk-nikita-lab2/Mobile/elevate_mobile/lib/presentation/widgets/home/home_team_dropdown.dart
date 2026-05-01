import 'package:elevate_mobile/domain/entities/dashboard/dashboard.dart';
import 'package:flutter/material.dart';

class HomeTeamDropdown extends StatelessWidget {
  final int? effectiveId;
  final List<Dashboard> dashboards;
  final ValueChanged<int> onChanged;

  const HomeTeamDropdown({
    super.key,
    required this.effectiveId,
    required this.dashboards,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Team',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.groups),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: effectiveId,
          items: dashboards
              .map(
                (d) => DropdownMenuItem(
                  value: d.teamId,
                  child: Text(d.teamName),
                ),
              )
              .toList(),
          onChanged: (id) {
            if (id != null) onChanged(id);
          },
        ),
      ),
    );
  }
}
