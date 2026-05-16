import 'package:elevate_mobile/domain/entities/activity/activity.dart';
import 'package:elevate_mobile/domain/repositories/activity/activity_repository.dart';

class GetActivityUseCase {
  final ActivityRepository repository;

  GetActivityUseCase(this.repository);

  Future<List<Activity>> call({int? teamId}) {
    return repository.getActivity(teamId: teamId);
  }
}