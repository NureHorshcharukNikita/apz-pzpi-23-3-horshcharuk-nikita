import 'package:elevate_mobile/domain/entities/activity/activity.dart';

abstract class ActivityRepository {
  Future<List<Activity>> getActivity({int? teamId});
}