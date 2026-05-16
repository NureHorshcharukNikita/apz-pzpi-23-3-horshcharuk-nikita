import 'package:elevate_mobile/core/config/app_config.dart';
import 'package:elevate_mobile/providers/core/dio_provider.dart';
import 'package:elevate_mobile/data/repositories/achievements_repository_impl.dart';
import 'package:elevate_mobile/data/datasources/remote/achievements/achievements_api.dart';
import 'package:elevate_mobile/data/datasources/remote/achievements/achievements_api_fake.dart';
import 'package:elevate_mobile/data/datasources/remote/achievements/achievements_api_impl.dart';
import 'package:elevate_mobile/domain/repositories/achievements/achievements_repository.dart';
import 'package:elevate_mobile/domain/usecases/achievements/get_achievements_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final achievementsApiProvider =
Provider<AchievementsApi>((ref) {
  if (AppConfig.useMockServices) {
    return AchievementsApiFake();
  }

  return AchievementsApiImpl(ref.read(dioProvider));
});

final achievementsRepositoryProvider =
Provider<AchievementsRepository>((ref) {
  return AchievementsRepositoryImpl(
    ref.read(achievementsApiProvider),
  );
});

final getAchievementsUseCaseProvider =
Provider<GetAchievementsUseCase>((ref) {
  return GetAchievementsUseCase(
    ref.read(achievementsRepositoryProvider),
  );
});