import 'package:elevate_mobile/domain/repositories/team/team_repository.dart';

class LeaveTeamUseCase {
  final TeamRepository repository;

  LeaveTeamUseCase(this.repository);

  Future<void> call(int teamId) => repository.leaveTeam(teamId);
}
