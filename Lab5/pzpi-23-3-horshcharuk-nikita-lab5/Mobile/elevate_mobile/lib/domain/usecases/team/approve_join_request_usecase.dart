import 'package:elevate_mobile/domain/repositories/team/team_repository.dart';

class ApproveJoinRequestUseCase {
  final TeamRepository repository;

  ApproveJoinRequestUseCase(this.repository);

  Future<void> call(int teamId, int requestId) =>
      repository.approveJoinRequest(teamId, requestId);
}
