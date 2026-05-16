import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:elevate_mobile/domain/entities/team/team_member.dart';

part 'team_members_state.freezed.dart';

@freezed
class TeamMembersState with _$TeamMembersState {
  const factory TeamMembersState.initial() = _Initial;

  const factory TeamMembersState.loading() = _Loading;

  const factory TeamMembersState.loaded(List<TeamMember> members) = _Loaded;

  const factory TeamMembersState.error(
      String message,
      ) = _Error;
}