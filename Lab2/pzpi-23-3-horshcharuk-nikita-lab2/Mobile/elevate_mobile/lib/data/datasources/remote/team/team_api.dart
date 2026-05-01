import 'package:elevate_mobile/data/models/team/join/my_pending_join_request_model.dart';
import 'package:elevate_mobile/data/models/team/join/team_join_request_model.dart';
import 'package:elevate_mobile/data/models/team/members/member_badge_award_model.dart';
import 'package:elevate_mobile/data/models/team/members/team_member_model.dart';
import 'package:elevate_mobile/data/models/team/core/team_model.dart';

abstract class TeamApi {

  Future<List<TeamModel>> getMyTeams();

  Future<TeamModel> getTeam(int id);

  Future<List<TeamMemberModel>> getTeamMembers(int teamId);

  Future<TeamMemberModel> setMemberTeamPoints(
    int teamId,
    int memberUserId,
    int teamPoints,
  );

  Future<List<MemberBadgeAwardModel>> getMemberBadgeAwards(
    int teamId,
    int memberUserId,
  );

  Future<MemberBadgeAwardModel> grantMemberBadge(
    int teamId,
    int memberUserId,
    int badgeId,
  );

  Future<void> revokeMemberBadgeAward(
    int teamId,
    int memberUserId,
    int userTeamBadgeId,
  );

  Future<List<TeamModel>> discoverTeams(String query);

  Future<void> joinTeam(int teamId);

  Future<List<MyPendingJoinRequestModel>> getMyPendingJoinRequests();

  Future<void> cancelMyJoinRequest(int teamId);

  Future<void> leaveTeam(int teamId);

  Future<void> removeTeamMember(int teamId, int memberUserId);

  Future<List<TeamJoinRequestModel>> getTeamJoinRequests(int teamId);

  Future<void> approveJoinRequest(int teamId, int requestId);

  Future<void> rejectJoinRequest(int teamId, int requestId);

  Future<TeamModel> createTeam({
    required String name,
    String? description,
    int? maxMembers,
  });

  Future<TeamModel> updateTeam(
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