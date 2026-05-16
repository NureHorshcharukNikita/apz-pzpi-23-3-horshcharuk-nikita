import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elevate_mobile/providers/team/team_provider.dart';
import 'package:elevate_mobile/domain/usecases/team/get_team_members_usecase.dart';
import 'package:elevate_mobile/presentation/states/team/team_members_state.dart';

final teamMembersViewModelProvider =
    StateNotifierProvider.family<TeamMembersViewModel, TeamMembersState, int>(
  (ref, teamId) => TeamMembersViewModel(
    ref.read(getTeamMembersUseCaseProvider),
    teamId,
  ),
);

class TeamMembersViewModel
    extends StateNotifier<TeamMembersState> {

  final GetTeamMembersUseCase getMembers;
  final int teamId;

  TeamMembersViewModel(
      this.getMembers,
      this.teamId,
      ) : super(const TeamMembersState.initial()) {
    load();
  }

  Future<void> load({bool showLoadingIndicator = true}) async {
    try {
      if (showLoadingIndicator) {
        state = const TeamMembersState.loading();
      }

      final members = await getMembers(teamId);

      state = TeamMembersState.loaded(members);

    } catch (e) {
      state = TeamMembersState.error(mapError(e));
    }
  }
}