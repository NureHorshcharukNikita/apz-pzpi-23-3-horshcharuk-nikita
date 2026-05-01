import 'package:elevate_mobile/domain/entities/dashboard/dashboard.dart';
import 'package:elevate_mobile/domain/repositories/dashboard/dashboard_repository.dart';

class GetDashboardUseCase {
  final DashboardRepository repository;

  GetDashboardUseCase(this.repository);

  Future<List<Dashboard>> call() {
    return repository.getDashboard();
  }
}