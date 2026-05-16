import 'package:elevate_mobile/data/datasources/remote/leaderboard/leaderboard_api.dart';
import 'package:elevate_mobile/domain/entities/leaderboard/leaderboard_user.dart';
import 'package:elevate_mobile/domain/repositories/leaderboard/leaderboard_repository.dart';

class LeaderboardRepositoryImpl
    implements LeaderboardRepository {
  final LeaderboardApi api;

  LeaderboardRepositoryImpl(this.api);

  @override
  Future<List<LeaderboardUser>> getLeaderboard(
      String period,
      ) async {
    final result = await api.getLeaderboard(period);

    return result.map((e) => e.toEntity()).toList();
  }
}