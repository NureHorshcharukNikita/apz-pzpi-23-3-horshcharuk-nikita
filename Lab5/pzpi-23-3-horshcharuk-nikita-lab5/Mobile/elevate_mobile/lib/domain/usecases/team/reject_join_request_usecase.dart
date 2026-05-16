import 'package:elevate_mobile/domain/repositories/team/team_repository.dart';

class RejectJoinRequestUseCase {
  final TeamRepository repository;

  RejectJoinRequestUseCase(this.repository);

  Future<void> call(int teamId, int requestId) =>
      repository.rejectJoinRequest(teamId, requestId);
}
