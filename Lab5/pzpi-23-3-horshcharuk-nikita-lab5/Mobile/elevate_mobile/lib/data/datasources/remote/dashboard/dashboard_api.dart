import 'package:elevate_mobile/data/models/dashboard/dashboard_model.dart';

abstract class DashboardApi {
  Future<List<DashboardModel>> getDashboard();
}