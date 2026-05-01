import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elevate_mobile/providers/team/team_provider.dart';

import 'package:elevate_mobile/domain/usecases/team/get_my_teams_usecase.dart';

import 'package:elevate_mobile/presentation/states/team/my_teams_state.dart';

final myTeamsViewModelProvider =
StateNotifierProvider<MyTeamsViewModel, MyTeamsState>(
      (ref) => MyTeamsViewModel(
    ref.read(getMyTeamsUseCaseProvider),
  ),
);

class MyTeamsViewModel
    extends StateNotifier<MyTeamsState> {

  final GetMyTeamsUseCase getMyTeams;

  MyTeamsViewModel(this.getMyTeams)
      : super(const MyTeamsState.initial()) {
    load();
  }

  Future<void> load({bool showLoadingIndicator = true}) async {
    try {
      if (showLoadingIndicator) {
        state = const MyTeamsState.loading();
      }

      final teams = await getMyTeams();

      state = MyTeamsState.loaded(teams);
    } catch (e) {
      state = MyTeamsState.error(mapError(e));
    }
  }
}