import 'package:elevate_mobile/domain/repositories/team/team_repository.dart';

class DeleteTeamUseCase {
  final TeamRepository repository;

  DeleteTeamUseCase(this.repository);

  Future<void> call(int teamId) => repository.deleteTeam(teamId);
}
