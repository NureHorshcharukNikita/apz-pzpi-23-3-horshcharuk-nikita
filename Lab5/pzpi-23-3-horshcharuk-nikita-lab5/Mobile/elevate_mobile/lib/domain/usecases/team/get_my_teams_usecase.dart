import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/domain/repositories/team/team_repository.dart';

class GetMyTeamsUseCase {
  final TeamRepository repository;

  GetMyTeamsUseCase(this.repository);

  Future<List<Team>> call() {
    return repository.getMyTeams();
  }
}