import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:elevate_mobile/domain/entities/activity/activity.dart';

part 'activity_state.freezed.dart';

@freezed
class ActivityState with _$ActivityState {
  const factory ActivityState.initial() = _Initial;

  const factory ActivityState.loading() = _Loading;

  const factory ActivityState.loaded(
      List<Activity> activity,
      ) = _Loaded;

  const factory ActivityState.error(String message) = _Error;
}