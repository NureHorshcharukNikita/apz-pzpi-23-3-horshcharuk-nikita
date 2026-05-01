import 'package:elevate_mobile/data/models/activity/activity_model.dart';

abstract class ActivityApi {
  Future<List<ActivityModel>> getActivity({int? teamId});
}