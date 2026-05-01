import 'package:elevate_mobile/data/models/leaderboard/leaderboard_user_model.dart';

abstract class LeaderboardApi {
  Future<List<LeaderboardUserModel>> getLeaderboard(String period);
}