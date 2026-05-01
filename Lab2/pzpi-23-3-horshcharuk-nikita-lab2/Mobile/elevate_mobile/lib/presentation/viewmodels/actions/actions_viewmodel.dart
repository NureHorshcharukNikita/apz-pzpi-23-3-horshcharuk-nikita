import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:elevate_mobile/domain/entities/action/action_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elevate_mobile/domain/usecases/actions/execute_action_usecase.dart';
import 'package:elevate_mobile/domain/usecases/actions/get_team_action_types_usecase.dart';
import 'package:elevate_mobile/presentation/states/actions/actions_state.dart';
import 'package:elevate_mobile/providers/actions/actions_provider.dart';

final actionsViewModelProvider = StateNotifierProvider.family<
    ActionsViewModel, ActionsState, int>(
      (ref, teamId) => ActionsViewModel(
    ref.read(getTeamActionTypesUseCaseProvider),
    ref.read(executeActionUseCaseProvider),
    teamId,
  ),
);

class ActionsViewModel extends StateNotifier<ActionsState> {
  final GetTeamActionTypesUseCase getTeamActionTypesUseCase;
  final ExecuteActionUseCase executeActionUseCase;
  final int teamId;

  ActionsViewModel(
      this.getTeamActionTypesUseCase,
      this.executeActionUseCase,
      this.teamId,
      ) : super(const ActionsState.initial()) {
    load();
  }

  Future<void> load() async {
    try {
      state = const ActionsState.loading();

      final types = await getTeamActionTypesUseCase(teamId);

      state = ActionsState.loaded(
        actionTypes: types,
        lastResult: null,
      );
    } catch (e) {
      state = ActionsState.error(mapError(e));
    }
  }

  Future<void> execute({
    required int userId,
    required int actionTypeId,
    required String sourceType,
    int? sourceUserId,
    String? comment,
    DateTime? occurredAt,
  }) async {
    final currentTypes = state.maybeWhen(
      loaded: (actionTypes, lastResult) => actionTypes,
      orElse: () => <ActionType>[],
    );
    if (currentTypes.isEmpty) return;

    try {
      final result = await executeActionUseCase(
        teamId: teamId,
        userId: userId,
        actionTypeId: actionTypeId,
        sourceType: sourceType,
        sourceUserId: sourceUserId,
        comment: comment,
        occurredAt: occurredAt,
      );

      state = ActionsState.loaded(
        actionTypes: List<ActionType>.from(currentTypes),
        lastResult: result,
      );
    } catch (e) {
      state = ActionsState.error(mapError(e));
    }
  }

  void clearResult() {
    state.maybeWhen(
      loaded: (actionTypes, lastResult) {
        state = ActionsState.loaded(
          actionTypes: actionTypes,
          lastResult: null,
        );
      },
      orElse: () {},
    );
  }
}