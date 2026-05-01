import 'package:elevate_mobile/core/config/app_config.dart';
import 'package:elevate_mobile/data/repositories/leaderboard_repository_impl.dart';
import 'package:elevate_mobile/data/datasources/remote/leaderboard/leaderboard_api.dart';
import 'package:elevate_mobile/data/datasources/remote/leaderboard/leaderboard_api_fake.dart';
import 'package:elevate_mobile/data/datasources/remote/leaderboard/leaderboard_api_impl.dart';
import 'package:elevate_mobile/domain/repositories/leaderboard/leaderboard_repository.dart';
import 'package:elevate_mobile/domain/usecases/leaderboard/get_leaderboard_usecase.dart';
import 'package:elevate_mobile/providers/core/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final leaderboardApiProvider = Provider<LeaderboardApi>((ref) {
  if (AppConfig.useMockServices) {
    return LeaderboardApiFake();
  }

  return LeaderboardApiImpl(ref.read(dioProvider));
});

final leaderboardRepositoryProvider =
Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepositoryImpl(
    ref.read(leaderboardApiProvider),
  );
});

final getLeaderboardUseCaseProvider =
Provider<GetLeaderboardUseCase>((ref) {
  return GetLeaderboardUseCase(
    ref.read(leaderboardRepositoryProvider),
  );
});