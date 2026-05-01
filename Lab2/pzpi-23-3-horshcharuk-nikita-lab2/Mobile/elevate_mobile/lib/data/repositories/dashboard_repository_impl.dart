import 'package:elevate_mobile/data/datasources/remote/dashboard/dashboard_api.dart';
import 'package:elevate_mobile/domain/entities/dashboard/dashboard.dart';
import 'package:elevate_mobile/domain/repositories/dashboard/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardApi api;

  DashboardRepositoryImpl(this.api);

  @override
  Future<List<Dashboard>> getDashboard() async {
    final result = await api.getDashboard();
    return result.map((e) => e.toEntity()).toList();
  }
}