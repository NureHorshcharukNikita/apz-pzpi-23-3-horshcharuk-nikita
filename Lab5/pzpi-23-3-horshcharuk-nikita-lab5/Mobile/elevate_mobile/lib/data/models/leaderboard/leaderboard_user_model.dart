import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:elevate_mobile/domain/entities/leaderboard/leaderboard_user.dart';

part 'leaderboard_user_model.freezed.dart';
part 'leaderboard_user_model.g.dart';

@freezed
class LeaderboardUserModel with _$LeaderboardUserModel {
  const LeaderboardUserModel._();

  const factory LeaderboardUserModel({
    required int position,
    required String name,
    required int points,
  }) = _LeaderboardUserModel;

  factory LeaderboardUserModel.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardUserModelFromJson(json);

  LeaderboardUser toEntity() {
    return LeaderboardUser(
      position: position,
      name: name,
      points: points,
    );
  }
}