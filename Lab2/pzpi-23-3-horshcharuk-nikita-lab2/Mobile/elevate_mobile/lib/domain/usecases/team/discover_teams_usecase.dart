import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/domain/repositories/team/team_repository.dart';

class DiscoverTeamsUseCase {
  final TeamRepository repository;

  DiscoverTeamsUseCase(this.repository);

  Future<List<Team>> call(String query) {
    return repository.discoverTeams(query);
  }
}