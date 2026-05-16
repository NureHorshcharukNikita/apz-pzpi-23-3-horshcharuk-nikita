import 'package:elevate_mobile/domain/entities/dashboard/dashboard.dart';

abstract class DashboardRepository {
  Future<List<Dashboard>> getDashboard();
}