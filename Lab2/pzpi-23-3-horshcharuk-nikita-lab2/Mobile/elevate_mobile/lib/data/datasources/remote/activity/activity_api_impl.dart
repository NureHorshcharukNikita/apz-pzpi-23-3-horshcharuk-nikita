import 'package:dio/dio.dart';
import 'package:elevate_mobile/data/datasources/remote/activity/activity_api.dart';
import 'package:elevate_mobile/data/models/activity/activity_model.dart';

class ActivityApiImpl implements ActivityApi {
  final Dio dio;

  ActivityApiImpl(this.dio);

  @override
  Future<List<ActivityModel>> getActivity({int? teamId}) async {
    final response = await dio.get(
      '/users/me/activity',
      queryParameters:
          teamId != null ? <String, dynamic>{'teamId': teamId} : null,
    );

    final list = response.data as List<dynamic>;
    return list
        .map((e) => ActivityModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}