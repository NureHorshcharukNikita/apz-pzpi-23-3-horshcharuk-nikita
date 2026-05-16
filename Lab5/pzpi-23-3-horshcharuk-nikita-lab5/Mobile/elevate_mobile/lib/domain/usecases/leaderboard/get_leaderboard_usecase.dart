import 'package:elevate_mobile/domain/entities/leaderboard/leaderboard_user.dart';
import 'package:elevate_mobile/domain/repositories/leaderboard/leaderboard_repository.dart';

class GetLeaderboardUseCase {
  final LeaderboardRepository repository;

  GetLeaderboardUseCase(this.repository);

  Future<List<LeaderboardUser>> call(String period) {
    return repository.getLeaderboard(period);
  }
}