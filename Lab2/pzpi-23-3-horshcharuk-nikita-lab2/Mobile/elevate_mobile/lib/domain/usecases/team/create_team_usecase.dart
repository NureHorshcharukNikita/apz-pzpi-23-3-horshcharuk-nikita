import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/domain/repositories/team/team_repository.dart';

class CreateTeamUseCase {
  final TeamRepository repository;

  CreateTeamUseCase(this.repository);

  Future<Team> call({
    required String name,
    String? description,
    int? maxMembers,
  }) =>
      repository.createTeam(
        name: name,
        description: description,
        maxMembers: maxMembers,
      );
}
