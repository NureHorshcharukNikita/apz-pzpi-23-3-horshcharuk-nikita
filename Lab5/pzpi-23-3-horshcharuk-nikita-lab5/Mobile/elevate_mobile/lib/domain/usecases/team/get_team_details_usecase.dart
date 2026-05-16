import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/domain/repositories/team/team_repository.dart';

class GetTeamDetailsUseCase {
  final TeamRepository repository;

  GetTeamDetailsUseCase(this.repository);

  Future<Team> call(int id) {
    return repository.getTeam(id);
  }
}