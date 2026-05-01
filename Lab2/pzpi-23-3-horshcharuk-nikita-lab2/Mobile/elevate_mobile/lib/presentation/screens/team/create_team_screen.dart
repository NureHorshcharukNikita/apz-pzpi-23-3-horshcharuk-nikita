import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:elevate_mobile/core/router/app_router.dart';
import 'package:elevate_mobile/providers/team/refresh_teams_hub.dart';
import 'package:elevate_mobile/providers/team/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CreateTeamScreen extends ConsumerStatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  ConsumerState<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends ConsumerState<CreateTeamScreen> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _maxMembers = TextEditingController(text: '10');
  bool _saving = false;
  bool _unlimitedMembers = true;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _maxMembers.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a team name')),
      );
      return;
    }

    int? maxMembers;
    if (!_unlimitedMembers) {
      final cap = int.tryParse(_maxMembers.text.trim());
      if (cap == null || cap < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter max members (1 or more), or enable unlimited.'),
          ),
        );
        return;
      }
      maxMembers = cap;
    }

    setState(() => _saving = true);
    try {
      final team = await ref.read(createTeamUseCaseProvider).call(
            name: name,
            description: _description.text.trim().isEmpty
                ? null
                : _description.text.trim(),
            maxMembers: maxMembers,
          );
      await refreshTeamsHub(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team created')),
      );
      if (context.canPop()) {
        context.pop();
      }
      await context.push<void>(AppRoutes.teamDetailsById(team.id));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapError(e))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create team'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Team name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _description,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
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
            value: _unlimitedMembers,
            onChanged: _saving
                ? null
                : (v) {
                    setState(() => _unlimitedMembers = v);
                  },
          ),
          if (!_unlimitedMembers) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _maxMembers,
              decoration: const InputDecoration(
                labelText: 'Max members',
                helperText: 'Includes you. New joins blocked when full.',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create'),
          ),
        ],
      ),
    );
  }
}
