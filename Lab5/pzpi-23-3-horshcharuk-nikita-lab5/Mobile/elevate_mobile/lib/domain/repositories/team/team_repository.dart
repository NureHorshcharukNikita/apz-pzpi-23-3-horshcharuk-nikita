import 'package:elevate_mobile/domain/entities/team/my_pending_join_request.dart';
import 'package:elevate_mobile/domain/entities/team/member_badge_award.dart';
import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/domain/entities/team/team_join_request.dart';
import 'package:elevate_mobile/domain/entities/team/team_member.dart';

abstract class TeamRepository {

  Future<List<Team>> getMyTeams();

  Future<Team> getTeam(int id);

  Future<List<TeamMember>> getTeamMembers(int teamId);

  Future<TeamMember> setMemberTeamPoints(
    int teamId,
    int memberUserId,
    int teamPoints,
  );

  Future<List<MemberBadgeAward>> getMemberBadgeAwards(
    int teamId,
    int memberUserId,
  );

  Future<MemberBadgeAward> grantMemberBadge(
    int teamId,
    int memberUserId,
    int badgeId,
  );

  Future<void> revokeMemberBadgeAward(
    int teamId,
    int memberUserId,
    int userTeamBadgeId,
  );

  Future<List<Team>> discoverTeams(String query);

  Future<void> joinTeam(int teamId);

  Future<List<MyPendingJoinRequest>> getMyPendingJoinRequests();

  Future<void> cancelMyJoinRequest(int teamId);

  Future<void> leaveTeam(int teamId);

  Future<void> removeTeamMember(int teamId, int memberUserId);

  Future<List<TeamJoinRequest>> getTeamJoinRequests(int teamId);

  Future<void> approveJoinRequest(int teamId, int requestId);

  Future<void> rejectJoinRequest(int teamId, int requestId);

  Future<Team> createTeam({
    required String name,
    String? description,
    int? maxMembers,
  });

  Future<Team> updateTeam(
    int teamId, {
    required String name,
    String? description,
    int? levelPointsMode,
    bool updateMaxMembers = false,
    int? maxMembers,
  });

  Future<void> deleteTeam(int teamId);

  Future<void> createTeamLevel(
    int teamId, {
    String? name,
    required int requiredPoints,
    required int orderIndex,
  });

  Future<void> updateTeamLevel(
    int teamId,
    int levelId, {
    String? name,
    required int requiredPoints,
    required int orderIndex,
  });

  Future<void> createTeamBadge(
    int teamId, {
    required String code,
    required String name,
    String? description,
    String? iconCode,
    String? conditionType,
    int? conditionValue,
  });

  Future<void> updateTeamBadge(
    int teamId,
    int badgeId, {
    required String name,
    String? description,
    String? iconCode,
    String? conditionType,
    int? conditionValue,
  });

  Future<void> deleteTeamLevel(int teamId, int levelId);

  Future<void> deleteTeamBadge(int teamId, int badgeId);
}