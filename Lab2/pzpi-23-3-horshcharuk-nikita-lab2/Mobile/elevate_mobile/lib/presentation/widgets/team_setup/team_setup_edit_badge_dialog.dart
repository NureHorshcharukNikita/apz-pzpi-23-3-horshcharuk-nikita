import 'package:elevate_mobile/domain/entities/team/team_badge_info.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_threshold.dart';
import 'package:elevate_mobile/core/utils/team_badge_condition.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/team_setup_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool?> showTeamSetupEditBadgeDialog({
  required BuildContext context,
  required int teamId,
  required TeamBadgeInfo badge,
  required List<TeamLevelThreshold> levelsSorted,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => TeamSetupEditBadgeDialog(
      teamId: teamId,
      badge: badge,
      levelsSorted: levelsSorted,
    ),
  );
}

class TeamSetupEditBadgeDialog extends ConsumerStatefulWidget {
  final int teamId;
  final TeamBadgeInfo badge;
  final List<TeamLevelThreshold> levelsSorted;

  const TeamSetupEditBadgeDialog({
    super.key,
    required this.teamId,
    required this.badge,
    required this.levelsSorted,
  });

  @override
  ConsumerState<TeamSetupEditBadgeDialog> createState() =>
      _TeamSetupEditBadgeDialogState();
}

class _TeamSetupEditBadgeDialogState
    extends ConsumerState<TeamSetupEditBadgeDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _iconCtrl;
  late final TextEditingController _pointsCtrl;

  late int _mode;
  TeamLevelThreshold? _selectedLevel;

  String? _errorText;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final badge = widget.badge;
    _nameCtrl = TextEditingController(text: badge.name);
    _descCtrl = TextEditingController(text: badge.description ?? '');
    _iconCtrl = TextEditingController(text: badge.iconCode ?? '');
    final initialLevelMode = teamBadgeConditionIsLevelOrder(badge.conditionType);
    final initialPointsText =
        (!initialLevelMode && badge.conditionValue != null)
            ? '${badge.conditionValue}'
            : '0';
    _pointsCtrl = TextEditingController(text: initialPointsText);
    _mode = initialLevelMode ? 1 : 0;

    if (initialLevelMode &&
        badge.conditionValue != null &&
        widget.levelsSorted.isNotEmpty) {
      for (final l in widget.levelsSorted) {
        if (l.orderIndex == badge.conditionValue) {
          _selectedLevel = l;
          break;
        }
      }
    }
    _selectedLevel ??=
        widget.levelsSorted.isNotEmpty ? widget.levelsSorted.first : null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _iconCtrl.dispose();
    _pointsCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final nm = _nameCtrl.text.trim();
    if (nm.isEmpty) {
      setState(() => _errorText = 'Badge name is required');
      return;
    }
    final String conditionType;
    final int conditionValue;
    if (_mode == 0) {
      final p = int.tryParse(_pointsCtrl.text.trim());
      if (p == null || p < 0) {
        setState(
          () => _errorText = 'Enter a valid XP threshold (0 or more)',
        );
        return;
      }
      conditionType = TeamBadgeCondition.totalPoints;
      conditionValue = p;
    } else {
      if (widget.levelsSorted.isEmpty || _selectedLevel == null) {
        setState(
          () => _errorText =
              'Add levels first (Levels tab), or switch to Team XP.',
        );
        return;
      }
      conditionType = TeamBadgeCondition.levelOrder;
      conditionValue = _selectedLevel!.orderIndex;
    }
    final descTrim = _descCtrl.text.trim();
    final iconTrim = _iconCtrl.text.trim();
    setState(() {
      _saving = true;
      _errorText = null;
    });
    final err = await ref
        .read(teamSetupViewModelProvider(widget.teamId).notifier)
        .updateTeamBadge(
          badgeId: widget.badge.id,
          name: nm,
          description: descTrim.isEmpty ? null : descTrim,
          iconCode: iconTrim.isEmpty ? null : iconTrim,
          conditionType: conditionType,
          conditionValue: conditionValue,
        );
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _saving = false;
        _errorText = err;
      });
      return;
    }
    if (context.mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final ctx = context;
    final levelsSorted = widget.levelsSorted;
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: Text('Edit badge · ${widget.badge.code}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
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
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _iconCtrl,
                decoration: const InputDecoration(
                  labelText: 'Icon code (optional)',
                  border: OutlineInputBorder(),
                ),
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
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
              const SizedBox(height: 12),
              if (_mode == 0)
                TextField(
                  controller: _pointsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Minimum team XP',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                )
              else if (levelsSorted.isEmpty)
                Text(
                  'No levels defined — add levels or switch to Team XP.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                )
              else
                DropdownButtonFormField<TeamLevelThreshold>(
                  value: _selectedLevel,
                  decoration: const InputDecoration(
                    labelText: 'Level',
                    border: OutlineInputBorder(),
                  ),
                  items: levelsSorted
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _saving ? null : _onSave,
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }
}
