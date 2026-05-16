import 'package:flutter/material.dart';

class TeamSetupTeamInfoTab extends StatelessWidget {
  final TextEditingController teamName;
  final TextEditingController teamDesc;
  final TextEditingController teamMaxMembers;
  final bool unlimitedMembers;
  final ValueChanged<bool>? onUnlimitedMembersChanged;
  final bool busy;
  final VoidCallback onSave;

  const TeamSetupTeamInfoTab({
    super.key,
    required this.teamName,
    required this.teamDesc,
    required this.teamMaxMembers,
    required this.unlimitedMembers,
    required this.onUnlimitedMembersChanged,
    required this.busy,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Name and description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: teamName,
          decoration: const InputDecoration(
            labelText: 'Team name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: teamDesc,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 20),
        Text(
          'Team size',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Unlimited members'),
          subtitle: Text(
            'Turn off to set a maximum team size (you count as a member).',
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
            ),
          ),
          value: unlimitedMembers,
          onChanged: onUnlimitedMembersChanged,
        ),
        if (!unlimitedMembers) ...[
          const SizedBox(height: 8),
          TextField(
            controller: teamMaxMembers,
            decoration: const InputDecoration(
              labelText: 'Max members',
              helperText: 'Includes you. New joins blocked when full.',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
        const SizedBox(height: 20),
        FilledButton(
          onPressed: busy ? null : onSave,
          child: busy
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save team'),
        ),
      ],
    );
  }
}
