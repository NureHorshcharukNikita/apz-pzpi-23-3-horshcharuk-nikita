import 'package:elevate_mobile/domain/entities/leaderboard/leaderboard_user.dart';

abstract class LeaderboardRepository {
  Future<List<LeaderboardUser>> getLeaderboard(String period);
}