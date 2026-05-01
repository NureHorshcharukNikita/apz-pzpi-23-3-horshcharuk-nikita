import 'package:elevate_mobile/core/config/app_config.dart';
import 'package:elevate_mobile/data/datasources/remote/profile/profile_api.dart';
import 'package:elevate_mobile/data/datasources/remote/profile/profile_api_fake.dart';
import 'package:elevate_mobile/data/datasources/remote/profile/profile_api_impl.dart';
import 'package:elevate_mobile/data/repositories/profile_repository_impl.dart';
import 'package:elevate_mobile/domain/repositories/profile/profile_repository.dart';
import 'package:elevate_mobile/domain/usecases/profile/get_profile_usecase.dart';
import 'package:elevate_mobile/domain/usecases/profile/update_profile_usecase.dart';
import 'package:elevate_mobile/domain/usecases/profile/upload_avatar_usecase.dart';
import 'package:elevate_mobile/providers/core/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileApiProvider = Provider<ProfileApi>((ref) {
  if (AppConfig.useMockServices) {
    return ProfileApiFake();
  }

  return ProfileApiImpl(ref.read(dioProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    ref.read(profileApiProvider),
  );
});

final getProfileUseCaseProvider =
Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(
    ref.read(profileRepositoryProvider),
  );
});

final updateProfileUseCaseProvider =
Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(
    ref.read(profileRepositoryProvider),
  );
});

final uploadAvatarUseCaseProvider =
Provider<UploadAvatarUseCase>((ref) {
  return UploadAvatarUseCase(
    ref.read(profileRepositoryProvider),
  );
});