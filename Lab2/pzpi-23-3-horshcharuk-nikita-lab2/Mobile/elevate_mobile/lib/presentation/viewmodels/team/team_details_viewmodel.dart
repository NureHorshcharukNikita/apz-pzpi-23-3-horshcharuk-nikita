import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elevate_mobile/providers/team/team_provider.dart';
import 'package:elevate_mobile/domain/usecases/team/get_team_details_usecase.dart';
import 'package:elevate_mobile/presentation/states/team/team_details_state.dart';

final teamDetailsViewModelProvider =
    StateNotifierProvider.family<TeamDetailsViewModel, TeamDetailsState, int>(
  (ref, id) => TeamDetailsViewModel(
    ref.read(getTeamDetailsUseCaseProvider),
    id,
  ),
);

class TeamDetailsViewModel
    extends StateNotifier<TeamDetailsState> {

  final GetTeamDetailsUseCase getTeam;
  final int id;

  TeamDetailsViewModel(
      this.getTeam,
      this.id,
      ) : super(const TeamDetailsState.initial()) {
    load();
  }

  Future<void> load({bool showLoadingIndicator = true}) async {
    try {
      if (showLoadingIndicator) {
        state = const TeamDetailsState.loading();
      }

      final team = await getTeam(id);

      state = TeamDetailsState.loaded(team);
    } catch (e) {
      state = TeamDetailsState.error(mapError(e));
    }
  }
}