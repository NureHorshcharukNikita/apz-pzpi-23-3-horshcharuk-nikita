import 'package:elevate_mobile/domain/entities/team/team_join_request.dart';
import 'package:elevate_mobile/domain/repositories/team/team_repository.dart';

class GetTeamJoinRequestsUseCase {
  final TeamRepository repository;

  GetTeamJoinRequestsUseCase(this.repository);

  Future<List<TeamJoinRequest>> call(int teamId) =>
      repository.getTeamJoinRequests(teamId);
}
