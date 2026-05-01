import 'package:elevate_mobile/core/config/app_config.dart';
import 'package:elevate_mobile/data/datasources/remote/auth/auth_api.dart';
import 'package:elevate_mobile/data/datasources/remote/auth/auth_api_fake.dart';
import 'package:elevate_mobile/data/datasources/remote/auth/auth_api_impl.dart';
import 'package:elevate_mobile/data/repositories/auth_repository_impl.dart';
import 'package:elevate_mobile/domain/repositories/auth/auth_repository.dart';
import 'package:elevate_mobile/domain/usecases/auth/login_usecase.dart';
import 'package:elevate_mobile/domain/usecases/auth/logout_usecase.dart';
import 'package:elevate_mobile/domain/usecases/auth/register_usecase.dart';
import 'package:elevate_mobile/providers/auth/auth_preferences_provider.dart';
import 'package:elevate_mobile/providers/core/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  if (AppConfig.useMockServices) {
    return AuthApiFake();
  }

  return AuthApiImpl(ref.read(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authApiProvider),
    ref.read(authPreferencesProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});