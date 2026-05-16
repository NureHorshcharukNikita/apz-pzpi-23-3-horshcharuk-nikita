import 'package:elevate_mobile/domain/repositories/team/team_repository.dart';

class KickTeamMemberUseCase {
  final TeamRepository repository;

  KickTeamMemberUseCase(this.repository);

  Future<void> call(int teamId, int memberUserId) =>
      repository.removeTeamMember(teamId, memberUserId);
}
