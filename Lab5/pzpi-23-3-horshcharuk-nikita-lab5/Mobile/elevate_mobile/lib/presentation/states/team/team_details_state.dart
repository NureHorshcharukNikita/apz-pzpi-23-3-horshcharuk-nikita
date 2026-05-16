import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:elevate_mobile/domain/entities/team/team.dart';

part 'team_details_state.freezed.dart';

@freezed
class TeamDetailsState with _$TeamDetailsState {
  const factory TeamDetailsState.initial() = _Initial;

  const factory TeamDetailsState.loading() = _Loading;

  const factory TeamDetailsState.loaded(Team team) = _Loaded;

  const factory TeamDetailsState.error(String message) = _Error;
}