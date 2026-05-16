import 'package:elevate_mobile/data/models/leaderboard/leaderboard_user_model.dart';
import 'package:elevate_mobile/data/datasources/remote/leaderboard/leaderboard_api.dart';

class LeaderboardApiFake implements LeaderboardApi {
  @override
  Future<List<LeaderboardUserModel>> getLeaderboard(
      String period,
      ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return List.generate(
      20,
          (index) => LeaderboardUserModel(
        position: index + 1,
        name: "User ${index + 1}",
        points: 1200 - (index * 10),
      ),
    );
  }
}