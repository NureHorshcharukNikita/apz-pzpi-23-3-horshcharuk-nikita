import 'package:elevate_mobile/domain/repositories/team/team_repository.dart';

class JoinTeamUseCase {
  final TeamRepository repository;

  JoinTeamUseCase(this.repository);

  Future<void> call(int teamId) => repository.joinTeam(teamId);
}
