import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:elevate_mobile/domain/entities/leaderboard/leaderboard_user.dart';

part 'leaderboard_state.freezed.dart';

@freezed
class LeaderboardState with _$LeaderboardState {
  const factory LeaderboardState.initial() = _Initial;

  const factory LeaderboardState.loading() = _Loading;

  const factory LeaderboardState.loaded(
      List<LeaderboardUser> users,
      ) = _Loaded;

  const factory LeaderboardState.error(String message) = _Error;
}