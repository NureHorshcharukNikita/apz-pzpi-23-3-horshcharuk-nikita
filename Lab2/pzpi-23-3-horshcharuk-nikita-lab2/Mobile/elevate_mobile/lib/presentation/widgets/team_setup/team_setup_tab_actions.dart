import 'package:elevate_mobile/domain/entities/action/action_type.dart';
import 'package:elevate_mobile/presentation/widgets/team_setup/team_setup_tiles.dart';
import 'package:elevate_mobile/presentation/widgets/load_error_view.dart';
import 'package:elevate_mobile/providers/actions/actions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamSetupActionsTab extends StatelessWidget {
  final int teamId;
  final ColorScheme scheme;
  final AsyncValue<List<ActionType>> actionTypesAsync;
  final TextEditingController search;
  final VoidCallback onSearchChanged;
  final List<ActionType> Function(List<ActionType>, String) filterActionTypes;
  final void Function(ActionType) onEditAction;
  final void Function(ActionType) onDeleteAction;

  const TeamSetupActionsTab({
    super.key,
    required this.teamId,
    required this.scheme,
    required this.actionTypesAsync,
    required this.search,
    required this.onSearchChanged,
    required this.filterActionTypes,
    required this.onEditAction,
    required this.onDeleteAction,
  });

  @override
  Widget build(BuildContext context) {
    return actionTypesAsync.when(
      data: (List<ActionType> types) {
        final filtered = filterActionTypes(types, search.text);
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          children: [
            TextField(
              controller: search,
              onChanged: (_) => onSearchChanged(),
              decoration: const InputDecoration(
                hintText: 'Search action types',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Action types (${filtered.length}/${types.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            if (types.isEmpty)
              Text(
                'No action types yet. Tap + to add.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              )
            else if (filtered.isEmpty)
              Text(
                'No matches.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              )
            else
              ...filtered.map(
                (t) => TeamSetupActionTypeTile(
                  type: t,
                  onEdit: () => onEditAction(t),
                  onDelete: () => onDeleteAction(t),
                ),
              ),
            const SizedBox(height: 24),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Consumer(
          builder: (context, ref, _) {
            return LoadErrorView.fromError(
              e,
              onRetry: () {
                ref.invalidate(teamSetupActionTypesProvider(teamId));
              },
            );
          },
        ),
      ),
    );
  }
}
