import 'package:elevate_mobile/core/config/app_config.dart';
import 'package:elevate_mobile/data/datasources/remote/activity/activity_api.dart';
import 'package:elevate_mobile/data/datasources/remote/activity/activity_api_fake.dart';
import 'package:elevate_mobile/data/datasources/remote/activity/activity_api_impl.dart';
import 'package:elevate_mobile/providers/core/dio_provider.dart';
import 'package:elevate_mobile/data/repositories/activity_repository_impl.dart';
import 'package:elevate_mobile/domain/repositories/activity/activity_repository.dart';
import 'package:elevate_mobile/domain/usecases/activity/get_activity_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activityApiProvider = Provider<ActivityApi>((ref) {
  if (AppConfig.useMockServices) {
    return ActivityApiFake();
  }

  return ActivityApiImpl(ref.read(dioProvider));
});

final activityRepositoryProvider =
Provider<ActivityRepository>((ref) {
  return ActivityRepositoryImpl(
    ref.read(activityApiProvider),
  );
});

final getActivityUseCaseProvider =
Provider<GetActivityUseCase>((ref) {
  return GetActivityUseCase(
    ref.read(activityRepositoryProvider),
  );
});