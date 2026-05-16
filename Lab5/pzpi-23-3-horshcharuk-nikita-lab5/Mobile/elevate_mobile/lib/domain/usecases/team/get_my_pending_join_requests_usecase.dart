import 'package:elevate_mobile/domain/entities/team/my_pending_join_request.dart';
import 'package:elevate_mobile/domain/repositories/team/team_repository.dart';

class GetMyPendingJoinRequestsUseCase {
  final TeamRepository repository;

  GetMyPendingJoinRequestsUseCase(this.repository);

  Future<List<MyPendingJoinRequest>> call() =>
      repository.getMyPendingJoinRequests();
}
