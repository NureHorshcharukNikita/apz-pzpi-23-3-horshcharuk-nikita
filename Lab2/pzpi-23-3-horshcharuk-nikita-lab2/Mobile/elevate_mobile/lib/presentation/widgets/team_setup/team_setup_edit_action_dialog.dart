import 'package:elevate_mobile/domain/entities/action/action_type.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/team_setup_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool?> showTeamSetupEditActionDialog({
  required BuildContext context,
  required int teamId,
  required ActionType type,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => TeamSetupEditActionDialog(
      teamId: teamId,
      type: type,
    ),
  );
}

class TeamSetupEditActionDialog extends ConsumerStatefulWidget {
  final int teamId;
  final ActionType type;

  const TeamSetupEditActionDialog({
    super.key,
    required this.teamId,
    required this.type,
  });

  @override
  ConsumerState<TeamSetupEditActionDialog> createState() =>
      _TeamSetupEditActionDialogState();
}

class _TeamSetupEditActionDialogState
    extends ConsumerState<TeamSetupEditActionDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _pointsCtrl;
  late final TextEditingController _catCtrl;

  bool _active = true;
  String? _errorText;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final type = widget.type;
    _nameCtrl = TextEditingController(text: type.name);
    _descCtrl = TextEditingController(text: type.description ?? '');
    _pointsCtrl = TextEditingController(text: '${type.defaultPoints}');
    _catCtrl = TextEditingController(text: type.category ?? '');
    _active = type.isActive;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _pointsCtrl.dispose();
    _catCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final nm = _nameCtrl.text.trim();
    if (nm.isEmpty) {
      setState(() => _errorText = 'Name is required');
      return;
    }
    final ptsText = _pointsCtrl.text.trim();
    if (ptsText.isEmpty) {
      setState(() => _errorText = 'Enter default points');
      return;
    }
    final pts = int.tryParse(ptsText);
    if (pts == null) {
      setState(
        () => _errorText = 'Default points must be a whole number',
      );
      return;
    }
    final descTrim = _descCtrl.text.trim();
    final catTrim = _catCtrl.text.trim();
    setState(() {
      _saving = true;
      _errorText = null;
    });
    final err = await ref
        .read(teamSetupViewModelProvider(widget.teamId).notifier)
        .updateActionType(
          actionTypeId: widget.type.id,
          name: nm,
          description: descTrim.isEmpty ? null : descTrim,
          defaultPoints: pts,
          category: catTrim.isEmpty ? null : catTrim,
          isActive: _active,
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
        title: Text('Edit · ${widget.type.code}'),
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
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                subtitle: const Text(
                  'Inactive types are hidden when logging actions',
                ),
                value: _active,
                onChanged: _saving ? null : (v) => setState(() => _active = v),
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
