import 'package:elevate_mobile/domain/repositories/team/team_repository.dart';

class CancelMyJoinRequestUseCase {
  final TeamRepository repository;

  CancelMyJoinRequestUseCase(this.repository);

  Future<void> call(int teamId) => repository.cancelMyJoinRequest(teamId);
}
