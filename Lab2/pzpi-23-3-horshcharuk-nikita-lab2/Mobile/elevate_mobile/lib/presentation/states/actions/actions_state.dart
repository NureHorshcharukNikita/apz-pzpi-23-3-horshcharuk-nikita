import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:elevate_mobile/domain/entities/action/action_result.dart';
import 'package:elevate_mobile/domain/entities/action/action_type.dart';

part 'actions_state.freezed.dart';

@freezed
class ActionsState with _$ActionsState {
  const factory ActionsState.initial() = _Initial;

  const factory ActionsState.loading() = _Loading;

  const factory ActionsState.loaded({
    required List<ActionType> actionTypes,
    ActionResult? lastResult,
  }) = _Loaded;

  const factory ActionsState.error(String message) = _Error;
}