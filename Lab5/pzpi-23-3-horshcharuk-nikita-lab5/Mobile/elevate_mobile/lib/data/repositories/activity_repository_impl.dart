import 'package:elevate_mobile/data/datasources/remote/activity/activity_api.dart';
import 'package:elevate_mobile/domain/entities/activity/activity.dart';
import 'package:elevate_mobile/domain/repositories/activity/activity_repository.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityApi api;

  ActivityRepositoryImpl(this.api);

  @override
  Future<List<Activity>> getActivity({int? teamId}) async {
    final result = await api.getActivity(teamId: teamId);

    return result.map((e) => e.toEntity()).toList();
  }
}