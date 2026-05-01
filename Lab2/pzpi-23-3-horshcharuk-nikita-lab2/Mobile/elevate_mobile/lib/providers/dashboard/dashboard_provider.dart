import 'package:elevate_mobile/core/config/app_config.dart';
import 'package:elevate_mobile/data/repositories/dashboard_repository_impl.dart';
import 'package:elevate_mobile/data/datasources/remote/dashboard/dashboard_api.dart';
import 'package:elevate_mobile/data/datasources/remote/dashboard/dashboard_api_fake.dart';
import 'package:elevate_mobile/data/datasources/remote/dashboard/dashboard_api_impl.dart';
import 'package:elevate_mobile/domain/repositories/dashboard/dashboard_repository.dart';
import 'package:elevate_mobile/domain/usecases/dashboard/get_dashboard_usecase.dart';
import 'package:elevate_mobile/providers/core/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardApiProvider = Provider<DashboardApi>((ref) {
  if (AppConfig.useMockServices) {
    return DashboardApiFake();
  }

  return DashboardApiImpl(ref.read(dioProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.read(dashboardApiProvider));
});

final getDashboardUseCaseProvider = Provider<GetDashboardUseCase>((ref) {
  return GetDashboardUseCase(ref.read(dashboardRepositoryProvider));
});