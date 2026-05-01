import 'package:dio/dio.dart';
import 'package:elevate_mobile/data/datasources/remote/dashboard/dashboard_api.dart';
import 'package:elevate_mobile/data/models/dashboard/dashboard_model.dart';

class DashboardApiImpl implements DashboardApi {
  final Dio dio;

  DashboardApiImpl(this.dio);

  @override
  Future<List<DashboardModel>> getDashboard() async {
    final response = await dio.get('/users/me/dashboard');

    final list = response.data as List<dynamic>;
    return list
        .map((e) =>
            DashboardModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}