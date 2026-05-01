import 'package:elevate_mobile/presentation/widgets/team_actions/team_action_type_card.dart';
import 'package:elevate_mobile/presentation/widgets/team_actions/team_actions_result_dialog.dart';
import 'package:elevate_mobile/presentation/viewmodels/actions/actions_viewmodel.dart';
import 'package:elevate_mobile/presentation/widgets/load_error_view.dart';
import 'package:elevate_mobile/providers/auth/auth_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamActionsScreen extends ConsumerWidget {
  final int teamId;

  const TeamActionsScreen({
    super.key,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(actionsViewModelProvider(teamId));

    ref.listen(actionsViewModelProvider(teamId), (previous, next) {
      final lastResult = next.maybeWhen(
        loaded: (_, lr) => lr,
        orElse: () => null,
      );
      if (lastResult == null) return;

      final prevResult = previous?.maybeWhen(
        loaded: (_, lr) => lr,
        orElse: () => null,
      );
      if (prevResult?.actionEventId == lastResult.actionEventId) return;

      showTeamActionCompletedDialog(context, ref, teamId, lastResult);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Actions'),
      ),
      body: state.when(
        initial: () => const Center(
          child: CircularProgressIndicator(),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (message) => Center(
          child: LoadErrorView(
            message: message,
            onRetry: () {
              ref.read(actionsViewModelProvider(teamId).notifier).load();
            },
          ),
        ),
        loaded: (actionTypes, _) {
          if (actionTypes.isEmpty) {
            return const Center(
              child: Text('No actions available'),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(actionsViewModelProvider(teamId).notifier).load(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: actionTypes.length,
              itemBuilder: (context, index) {
                final action = actionTypes[index];
                return TeamActionTypeCard(
                  action: action,
                  onDo: () {
                    final userId =
                        ref.read(authPreferencesProvider).getUserId();
                    if (userId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Not signed in'),
                        ),
                      );
                      return;
                    }
                    ref
                        .read(actionsViewModelProvider(teamId).notifier)
                        .execute(
                          userId: userId,
                          actionTypeId: action.id,
                          sourceType: 'Mobile',
                          comment: 'Triggered from mobile app',
                          occurredAt: DateTime.now(),
                        );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
