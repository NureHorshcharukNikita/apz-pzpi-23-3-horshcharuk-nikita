import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:elevate_mobile/presentation/widgets/team_setup/team_setup_feedback.dart';
import 'package:elevate_mobile/providers/actions/actions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamSetupAddActionBottomSheet extends ConsumerStatefulWidget {
  final int teamId;

  const TeamSetupAddActionBottomSheet({super.key, required this.teamId});

  @override
  ConsumerState<TeamSetupAddActionBottomSheet> createState() =>
      _TeamSetupAddActionBottomSheetState();
}

class _TeamSetupAddActionBottomSheetState
    extends ConsumerState<TeamSetupAddActionBottomSheet> {
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _pointsCtrl;
  late final TextEditingController _catCtrl;

  var _busy = false;
  var _active = true;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController();
    _nameCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _pointsCtrl = TextEditingController(text: '0');
    _catCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _pointsCtrl.dispose();
    _catCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!mounted) return;
    setState(() => _formError = null);

    final code = _codeCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    if (code.isEmpty || name.isEmpty) {
      const msg = 'Action code and name are required';
      setState(() => _formError = msg);
      showTeamSetupFloatingSnack(context, msg);
      return;
    }
    final ptsText = _pointsCtrl.text.trim();
    if (ptsText.isEmpty) {
      const msg = 'Enter default points';
      setState(() => _formError = msg);
      showTeamSetupFloatingSnack(context, msg);
      return;
    }
    final pts = int.tryParse(ptsText);
    if (pts == null) {
      const msg = 'Default points must be a whole number';
      setState(() => _formError = msg);
      showTeamSetupFloatingSnack(context, msg);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(actionsRepositoryProvider).createTeamActionType(
            widget.teamId,
            code: code,
            name: name,
            description: _descCtrl.text.trim().isEmpty
                ? null
                : _descCtrl.text.trim(),
            defaultPoints: pts,
            category:
                _catCtrl.text.trim().isEmpty ? null : _catCtrl.text.trim(),
            isActive: _active,
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
                  'Add action type',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
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
                const SizedBox(height: 12),
                TextField(
                  controller: _pointsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Default points',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _catCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Category (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: _active,
                  onChanged: _busy ? null : (v) => setState(() => _active = v),
                ),
                const SizedBox(height: 12),
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
