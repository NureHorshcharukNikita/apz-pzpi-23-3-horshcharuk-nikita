import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_threshold.dart';
import 'package:elevate_mobile/core/utils/team_badge_condition.dart';
import 'package:elevate_mobile/presentation/widgets/team_setup/team_setup_feedback.dart';
import 'package:elevate_mobile/providers/team/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamSetupAddBadgeBottomSheet extends ConsumerStatefulWidget {
  final int teamId;
  final List<TeamLevelThreshold> levelsSorted;

  const TeamSetupAddBadgeBottomSheet({
    super.key,
    required this.teamId,
    required this.levelsSorted,
  });

  @override
  ConsumerState<TeamSetupAddBadgeBottomSheet> createState() =>
      _TeamSetupAddBadgeBottomSheetState();
}

class _TeamSetupAddBadgeBottomSheetState
    extends ConsumerState<TeamSetupAddBadgeBottomSheet> {
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _pointsCtrl;

  var _busy = false;
  var _mode = 0;
  TeamLevelThreshold? _selectedLevel;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController();
    _nameCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _pointsCtrl = TextEditingController(text: '0');
    _selectedLevel = widget.levelsSorted.isNotEmpty
        ? widget.levelsSorted.first
        : null;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _pointsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!mounted) return;
    setState(() => _formError = null);

    final code = _codeCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    if (code.isEmpty || name.isEmpty) {
      const msg = 'Badge code and name are required';
      setState(() => _formError = msg);
      showTeamSetupFloatingSnack(context, msg);
      return;
    }
    final String conditionType;
    final int conditionValue;
    if (_mode == 0) {
      final p = int.tryParse(_pointsCtrl.text.trim());
      if (p == null || p < 0) {
        const msg = 'Enter a valid XP threshold (0 or more)';
        setState(() => _formError = msg);
        showTeamSetupFloatingSnack(context, msg);
        return;
      }
      conditionType = TeamBadgeCondition.totalPoints;
      conditionValue = p;
    } else {
      if (widget.levelsSorted.isEmpty || _selectedLevel == null) {
        const msg =
            'Add at least one level first (Levels tab), or switch to Team XP.';
        setState(() => _formError = msg);
        showTeamSetupFloatingSnack(context, msg);
        return;
      }
      conditionType = TeamBadgeCondition.levelOrder;
      conditionValue = _selectedLevel!.orderIndex;
    }
    setState(() => _busy = true);
    try {
      await ref.read(teamRepositoryProvider).createTeamBadge(
            widget.teamId,
            code: code,
            name: name,
            description: _descCtrl.text.trim().isEmpty
                ? null
                : _descCtrl.text.trim(),
            conditionType: conditionType,
            conditionValue: conditionValue,
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        final msg = mapError(e);
        setState(() {
          _busy = false;
          _formError = msg;
        });
        showTeamSetupFloatingSnack(context, msg);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final levels = widget.levelsSorted;
    final scheme = Theme.of(context).colorScheme;
    return ScaffoldMessenger(
      child: Material(
        color: scheme.surface,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
            left: 16,
            right: 16,
            top: 8,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_formError != null) TeamSetupErrorBanner(message: _formError!),
                Text(
                  'Add badge',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose when members earn this badge: enough team XP, or '
                  'reaching a configured level order.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Code (unique)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment<int>(
                      value: 0,
                      label: Text('Team XP'),
                      icon: Icon(Icons.stars_outlined, size: 18),
                    ),
                    ButtonSegment<int>(
                      value: 1,
                      label: Text('Level'),
                      icon: Icon(Icons.military_tech_outlined, size: 18),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) {
                    setState(() => _mode = s.first);
                  },
                ),
                const SizedBox(height: 12),
                if (_mode == 0)
                  TextField(
                    controller: _pointsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Minimum team XP (member)',
                      helperText:
                          'Badge unlocks when member has at least this many points',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  )
                else if (levels.isEmpty)
                  Text(
                    'Add at least one level first, then you can attach a badge '
                    'to a level order.',
                    style: TextStyle(
                      color: scheme.error,
                    ),
                  )
                else
                  DropdownButtonFormField<TeamLevelThreshold>(
                    value: _selectedLevel,
                    decoration: const InputDecoration(
                      labelText: 'Level',
                      helperText:
                          'Unlocks when the member reaches this level (same progression as on Team details)',
                      border: OutlineInputBorder(),
                    ),
                    items: levels
                        .map(
                          (l) => DropdownMenuItem<TeamLevelThreshold>(
                            value: l,
                            child: Text(
                              'Level ${l.orderIndex} — ${l.requiredPoints} XP'
                              '${l.name.trim().isNotEmpty ? ' · ${l.name.trim()}' : ''}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedLevel = v),
                  ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
