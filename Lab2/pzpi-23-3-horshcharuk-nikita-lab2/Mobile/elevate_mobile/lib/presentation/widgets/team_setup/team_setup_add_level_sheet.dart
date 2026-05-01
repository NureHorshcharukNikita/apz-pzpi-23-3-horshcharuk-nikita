import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_points_mode.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_threshold.dart';
import 'package:elevate_mobile/core/utils/team_level_points_input.dart';
import 'package:elevate_mobile/presentation/widgets/team_setup/team_setup_feedback.dart';
import 'package:elevate_mobile/providers/team/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamSetupAddLevelBottomSheet extends ConsumerStatefulWidget {
  final int teamId;
  final TeamLevelPointsMode levelPointsMode;
  final List<TeamLevelThreshold> levelsSorted;
  final String initialOrderText;
  final String initialPointsText;

  const TeamSetupAddLevelBottomSheet({
    super.key,
    required this.teamId,
    required this.levelPointsMode,
    required this.levelsSorted,
    required this.initialOrderText,
    required this.initialPointsText,
  });

  @override
  ConsumerState<TeamSetupAddLevelBottomSheet> createState() =>
      _TeamSetupAddLevelBottomSheetState();
}

class _TeamSetupAddLevelBottomSheetState
    extends ConsumerState<TeamSetupAddLevelBottomSheet> {
  late final TextEditingController _orderCtrl;
  late final TextEditingController _pointsCtrl;
  late final TextEditingController _labelCtrl;
  var _busy = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _orderCtrl = TextEditingController(text: widget.initialOrderText);
    _pointsCtrl = TextEditingController(text: widget.initialPointsText);
    _labelCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _orderCtrl.dispose();
    _pointsCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!mounted) return;
    setState(() => _formError = null);

    final ord = int.tryParse(_orderCtrl.text.trim());
    if (ord == null || ord < 1) {
      const msg = 'Enter a level number ≥ 1';
      setState(() => _formError = msg);
      showTeamSetupFloatingSnack(context, msg);
      return;
    }
    final ptsText = _pointsCtrl.text.trim();
    if (ptsText.isEmpty) {
      const msg = 'Enter XP for this level';
      setState(() => _formError = msg);
      showTeamSetupFloatingSnack(context, msg);
      return;
    }
    final raw = int.tryParse(ptsText);
    if (raw == null) {
      const msg = 'XP must be a whole number';
      setState(() => _formError = msg);
      showTeamSetupFloatingSnack(context, msg);
      return;
    }
    if (raw < 0) {
      const msg = 'XP cannot be negative';
      setState(() => _formError = msg);
      showTeamSetupFloatingSnack(context, msg);
      return;
    }
    final prev = prevCumulativeBeforeOrder(widget.levelsSorted, ord);
    if (widget.levelPointsMode == TeamLevelPointsMode.absoluteTotals &&
        raw < prev) {
      final msg = 'Total XP must be at least $prev';
      setState(() => _formError = msg);
      showTeamSetupFloatingSnack(context, msg);
      return;
    }
    final rp = cumulativeFromLevelFormInput(
      mode: widget.levelPointsMode,
      orderIndex: ord,
      pointsField: raw,
      sortedAsc: widget.levelsSorted,
    );
    final label = _labelCtrl.text.trim();
    setState(() => _busy = true);
    try {
      await ref.read(teamRepositoryProvider).createTeamLevel(
            widget.teamId,
            name: label.isEmpty ? null : label,
            requiredPoints: rp,
            orderIndex: ord,
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
    final mode = widget.levelPointsMode;
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
                  'Add level',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  mode == TeamLevelPointsMode.relativeSegments
                      ? 'XP per level stacks. Example: 400, then 500 → '
                          '400 total, then 900 total.'
                      : 'XP is the running total from zero. Example: '
                          '400 for level 1, 500 for level 2 → only +100 XP after level 1.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
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
                    labelText: mode == TeamLevelPointsMode.relativeSegments
                        ? 'XP this level'
                        : 'Total XP',
                    helperText: mode == TeamLevelPointsMode.relativeSegments
                        ? 'Adds on top of lower levels'
                        : 'All team XP counted from 0',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _labelCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    helperText: 'Shown next to the level; leave empty to hide',
                    border: OutlineInputBorder(),
                  ),
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
