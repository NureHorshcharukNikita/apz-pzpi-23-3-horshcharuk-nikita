import 'package:elevate_mobile/data/datasources/remote/activity/activity_api.dart';
import 'package:elevate_mobile/data/models/activity/activity_model.dart';

class ActivityApiFake implements ActivityApi {
  @override
  Future<List<ActivityModel>> getActivity({int? teamId}) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final list = List.generate(
      20,
      (index) => ActivityModel(
        id: '$index',
        teamId: index.isEven ? 1 : 2,
        teamName: index.isEven ? 'Backend Team' : 'Mobile Team',
        type: 'points',
        description: 'Completed task ${index + 1}',
        points: 50,
        date: DateTime.now().subtract(
          Duration(hours: index * 2),
        ),
      ),
    );
    if (teamId == null) return list;
    return list.where((e) => e.teamId == teamId).toList();
  }
}