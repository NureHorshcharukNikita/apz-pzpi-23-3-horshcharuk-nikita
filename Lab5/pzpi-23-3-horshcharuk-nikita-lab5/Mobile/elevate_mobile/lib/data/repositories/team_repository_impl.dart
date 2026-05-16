import 'package:elevate_mobile/data/datasources/remote/team/team_api.dart';
import 'package:elevate_mobile/domain/entities/team/my_pending_join_request.dart';
import 'package:elevate_mobile/domain/entities/team/member_badge_award.dart';
import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/domain/entities/team/team_join_request.dart';
import 'package:elevate_mobile/domain/entities/team/team_member.dart';
import 'package:elevate_mobile/domain/repositories/team/team_repository.dart';

class TeamRepositoryImpl implements TeamRepository {

  final TeamApi api;

  TeamRepositoryImpl(this.api);

  @override
  Future<List<Team>> getMyTeams() async {
    final result = await api.getMyTeams();
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<Team> getTeam(int id) async {
    final result = await api.getTeam(id);
    return result.toEntity();
  }

  @override
  Future<List<TeamMember>> getTeamMembers(int teamId) async {
    final result = await api.getTeamMembers(teamId);
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<TeamMember> setMemberTeamPoints(
    int teamId,
    int memberUserId,
    int teamPoints,
  ) async {
    final m = await api.setMemberTeamPoints(teamId, memberUserId, teamPoints);
    return m.toEntity();
  }

  @override
  Future<List<MemberBadgeAward>> getMemberBadgeAwards(
    int teamId,
    int memberUserId,
  ) async {
    final list = await api.getMemberBadgeAwards(teamId, memberUserId);
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<MemberBadgeAward> grantMemberBadge(
    int teamId,
    int memberUserId,
    int badgeId,
  ) async {
    final m = await api.grantMemberBadge(teamId, memberUserId, badgeId);
    return m.toEntity();
  }

  @override
  Future<void> revokeMemberBadgeAward(
    int teamId,
    int memberUserId,
    int userTeamBadgeId,
  ) =>
      api.revokeMemberBadgeAward(teamId, memberUserId, userTeamBadgeId);

  @override
  Future<List<Team>> discoverTeams(String query) async {
    final result = await api.discoverTeams(query);
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> joinTeam(int teamId) => api.joinTeam(teamId);

  @override
  Future<List<MyPendingJoinRequest>> getMyPendingJoinRequests() async {
    final result = await api.getMyPendingJoinRequests();
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> cancelMyJoinRequest(int teamId) =>
      api.cancelMyJoinRequest(teamId);

  @override
  Future<void> leaveTeam(int teamId) => api.leaveTeam(teamId);

  @override
  Future<void> removeTeamMember(int teamId, int memberUserId) =>
      api.removeTeamMember(teamId, memberUserId);

  @override
  Future<List<TeamJoinRequest>> getTeamJoinRequests(int teamId) async {
    final result = await api.getTeamJoinRequests(teamId);
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> approveJoinRequest(int teamId, int requestId) =>
      api.approveJoinRequest(teamId, requestId);

  @override
  Future<void> rejectJoinRequest(int teamId, int requestId) =>
      api.rejectJoinRequest(teamId, requestId);

  @override
  Future<Team> createTeam({
    required String name,
    String? description,
    int? maxMembers,
  }) async {
    final result = await api.createTeam(
      name: name,
      description: description,
      maxMembers: maxMembers,
    );
    return result.toEntity();
  }

  @override
  Future<Team> updateTeam(
    int teamId, {
    required String name,
    String? description,
    int? levelPointsMode,
    bool updateMaxMembers = false,
    int? maxMembers,
  }) async {
    final result = await api.updateTeam(
      teamId,
      name: name,
      description: description,
      levelPointsMode: levelPointsMode,
      updateMaxMembers: updateMaxMembers,
      maxMembers: maxMembers,
    );
    return result.toEntity();
  }

  @override
  Future<void> deleteTeam(int teamId) => api.deleteTeam(teamId);

  @override
  Future<void> createTeamLevel(
    int teamId, {
    String? name,
    required int requiredPoints,
    required int orderIndex,
  }) =>
      api.createTeamLevel(
        teamId,
        name: name,
        requiredPoints: requiredPoints,
        orderIndex: orderIndex,
      );

  @override
  Future<void> updateTeamLevel(
    int teamId,
    int levelId, {
    String? name,
    required int requiredPoints,
    required int orderIndex,
  }) =>
      api.updateTeamLevel(
        teamId,
        levelId,
        name: name,
        requiredPoints: requiredPoints,
        orderIndex: orderIndex,
      );

  @override
  Future<void> createTeamBadge(
    int teamId, {
    required String code,
    required String name,
    String? description,
    String? iconCode,
    String? conditionType,
    int? conditionValue,
  }) =>
      api.createTeamBadge(
        teamId,
        code: code,
        name: name,
        description: description,
        iconCode: iconCode,
        conditionType: conditionType,
        conditionValue: conditionValue,
      );

  @override
  Future<void> updateTeamBadge(
    int teamId,
    int badgeId, {
    required String name,
    String? description,
    String? iconCode,
    String? conditionType,
    int? conditionValue,
  }) =>
      api.updateTeamBadge(
        teamId,
        badgeId,
        name: name,
        description: description,
        iconCode: iconCode,
        conditionType: conditionType,
        conditionValue: conditionValue,
      );

  @override
  Future<void> deleteTeamLevel(int teamId, int levelId) =>
      api.deleteTeamLevel(teamId, levelId);

  @override
  Future<void> deleteTeamBadge(int teamId, int badgeId) =>
      api.deleteTeamBadge(teamId, badgeId);
}