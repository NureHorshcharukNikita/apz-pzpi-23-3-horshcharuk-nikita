import 'package:elevate_mobile/domain/entities/team/team_member.dart';
import 'package:elevate_mobile/domain/repositories/team/team_repository.dart';

class GetTeamMembersUseCase {
  final TeamRepository repository;

  GetTeamMembersUseCase(this.repository);

  Future<List<TeamMember>> call(int teamId) {
    return repository.getTeamMembers(teamId);
  }
}