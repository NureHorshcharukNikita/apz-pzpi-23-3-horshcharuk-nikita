import 'package:elevate_mobile/presentation/screens/team/team_screen/team_screen_helpers.dart';
import 'package:flutter/material.dart';

class TeamDiscoverSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;

  const TeamDiscoverSearchField({
    super.key,
    required this.controller,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Search team...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: onSearchChanged,
      ),
    );
  }
}

class TeamDiscoverShowFilterBar extends StatelessWidget {
  final TeamDiscoverShowFilter value;
  final ValueChanged<TeamDiscoverShowFilter> onChanged;

  const TeamDiscoverShowFilterBar({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Show',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<TeamDiscoverShowFilter>(
            isExpanded: true,
            value: value,
            items: const [
              DropdownMenuItem(
                value: TeamDiscoverShowFilter.all,
                child: Text('All teams'),
              ),
              DropdownMenuItem(
                value: TeamDiscoverShowFilter.openSpots,
                child: Text('Has open spots'),
              ),
            ],
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ),
    );
  }
}
