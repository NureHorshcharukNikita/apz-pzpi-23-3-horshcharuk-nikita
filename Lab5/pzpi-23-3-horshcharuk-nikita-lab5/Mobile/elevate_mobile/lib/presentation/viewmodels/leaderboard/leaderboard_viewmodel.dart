import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:elevate_mobile/domain/usecases/leaderboard/get_leaderboard_usecase.dart';
import 'package:elevate_mobile/providers/leaderboard/leaderboard_provider.dart';
import 'package:elevate_mobile/presentation/states/leaderboard/leaderboard_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final leaderboardViewModelProvider =
StateNotifierProvider<LeaderboardViewModel, LeaderboardState>(
      (ref) => LeaderboardViewModel(
    ref.read(getLeaderboardUseCaseProvider),
  ),
);

class LeaderboardViewModel extends StateNotifier<LeaderboardState> {
  final GetLeaderboardUseCase getLeaderboard;

  String currentPeriod = 'all';

  LeaderboardViewModel(this.getLeaderboard)
      : super(const LeaderboardState.initial()) {
    load(currentPeriod);
  }

  Future<void> load([String? period]) async {
    try {
      if (period != null) {
        currentPeriod = period;
      }

      state = const LeaderboardState.loading();

      final users = await getLeaderboard(currentPeriod);

      state = LeaderboardState.loaded(users);
    } catch (e) {
      state = LeaderboardState.error(mapError(e));
    }
  }
}