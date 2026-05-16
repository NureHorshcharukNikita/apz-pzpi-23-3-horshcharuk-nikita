import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:elevate_mobile/domain/entities/team/team.dart';

part 'my_teams_state.freezed.dart';

@freezed
class MyTeamsState with _$MyTeamsState {
  const factory MyTeamsState.initial() = _Initial;

  const factory MyTeamsState.loading() = _Loading;

  const factory MyTeamsState.loaded(List<Team> teams) = _Loaded;

  const factory MyTeamsState.error(String message) = _Error;
}