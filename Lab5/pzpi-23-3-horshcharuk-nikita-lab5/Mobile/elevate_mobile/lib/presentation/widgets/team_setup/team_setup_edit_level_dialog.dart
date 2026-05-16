import 'package:elevate_mobile/domain/entities/team/team_level_points_mode.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_threshold.dart';
import 'package:elevate_mobile/core/utils/team_level_points_input.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/team_setup_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool?> showTeamSetupEditLevelDialog({
  required BuildContext context,
  required int teamId,
  required TeamLevelThreshold level,
  required TeamLevelPointsMode levelPointsMode,
  required List<TeamLevelThreshold> levelsSorted,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => TeamSetupEditLevelDialog(
      teamId: teamId,
      level: level,
      levelPointsMode: levelPointsMode,
      levelsSorted: levelsSorted,
    ),
  );
}

class TeamSetupEditLevelDialog extends ConsumerStatefulWidget {
  final int teamId;
  final TeamLevelThreshold level;
  final TeamLevelPointsMode levelPointsMode;
  final List<TeamLevelThreshold> levelsSorted;

  const TeamSetupEditLevelDialog({
    super.key,
    required this.teamId,
    required this.level,
    required this.levelPointsMode,
    required this.levelsSorted,
  });

  @override
  ConsumerState<TeamSetupEditLevelDialog> createState() =>
      _TeamSetupEditLevelDialogState();
}

class _TeamSetupEditLevelDialogState
    extends ConsumerState<TeamSetupEditLevelDialog> {
  late final TextEditingController _labelCtrl;
  late final TextEditingController _pointsCtrl;
  late final TextEditingController _orderCtrl;

  String? _errorText;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.level.name);
    final displayPts = widget.levelPointsMode ==
            TeamLevelPointsMode.relativeSegments
        ? segmentForLevel(widget.level, widget.levelsSorted)
        : widget.level.requiredPoints;
    _pointsCtrl = TextEditingController(text: '$displayPts');
    _orderCtrl = TextEditingController(text: '${widget.level.orderIndex}');
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _pointsCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final ord = int.tryParse(_orderCtrl.text.trim());
    if (ord == null || ord < 1) {
      setState(() => _errorText = 'Enter a level number ≥ 1');
      return;
    }
    final raw = int.tryParse(_pointsCtrl.text.trim());
    if (raw == null || raw < 0) {
      setState(() => _errorText = 'Enter a valid XP value');
      return;
    }
    final prev = prevCumulativeBeforeOrder(
      widget.levelsSorted,
      ord,
      excludeLevelId: widget.level.id,
    );
    if (widget.levelPointsMode == TeamLevelPointsMode.absoluteTotals &&
        raw < prev) {
      setState(() => _errorText = 'Total XP must be at least $prev');
      return;
    }
    final rp = cumulativeFromLevelFormInput(
      mode: widget.levelPointsMode,
      orderIndex: ord,
      pointsField: raw,
      sortedAsc: widget.levelsSorted,
      excludeLevelId: widget.level.id,
    );
    final label = _labelCtrl.text.trim();
    setState(() {
      _saving = true;
      _errorText = null;
    });
    final err = await ref
        .read(teamSetupViewModelProvider(widget.teamId).notifier)
        .updateTeamLevel(
          levelId: widget.level.id,
          orderIndex: ord,
          requiredPoints: rp,
          name: label.isEmpty ? null : label,
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
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: const Text('Edit level'),
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
              Text(
                widget.levelPointsMode == TeamLevelPointsMode.relativeSegments
                    ? 'XP this level stacks on lower levels.'
                    : 'XP is total team points from zero.',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _orderCtrl,
                decoration: const InputDecoration(
                  labelText: 'Level number',
                  helperText: '1, 2, 10…',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pointsCtrl,
                decoration: InputDecoration(
                  labelText: widget.levelPointsMode ==
                          TeamLevelPointsMode.relativeSegments
                      ? 'XP this level'
                      : 'Total XP',
                  helperText: widget.levelPointsMode ==
                          TeamLevelPointsMode.relativeSegments
                      ? 'Adds on top of lower levels'
                      : 'All team XP from 0',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _labelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  helperText:
                      'Shown next to the level; leave empty to hide',
                  border: OutlineInputBorder(),
                ),
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
