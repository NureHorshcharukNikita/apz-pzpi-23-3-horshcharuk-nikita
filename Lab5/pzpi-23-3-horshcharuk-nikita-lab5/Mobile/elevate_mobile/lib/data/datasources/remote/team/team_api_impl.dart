import 'package:dio/dio.dart';
import 'package:elevate_mobile/core/utils/api_json_helpers.dart';
import 'package:elevate_mobile/data/datasources/remote/team/team_api.dart';
import 'package:elevate_mobile/data/datasources/remote/team/team_api_mappers.dart';
import 'package:elevate_mobile/data/models/team/core/team_model.dart';
import 'package:elevate_mobile/data/models/team/join/my_pending_join_request_model.dart';
import 'package:elevate_mobile/data/models/team/join/team_join_request_model.dart';
import 'package:elevate_mobile/data/models/team/members/member_badge_award_model.dart';
import 'package:elevate_mobile/data/models/team/members/team_member_model.dart';

class TeamApiImpl implements TeamApi {
  final Dio dio;

  TeamApiImpl(this.dio);

  @override
  Future<List<TeamModel>> getMyTeams() async {
    final response = await dio.get('/users/me');
    final responseData = Map<String, dynamic>.from(response.data as Map);
    final teams = (responseData['teams'] as List?) ?? const [];

    return teams
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map(teamModelFromMyTeamsRow)
        .toList();
  }

  @override
  Future<TeamModel> getTeam(int id) async {
    final response = await dio.get('/teams/$id');
    final data = Map<String, dynamic>.from(response.data as Map);
    return teamModelFromDetailMap(data);
  }

  @override
  Future<List<TeamMemberModel>> getTeamMembers(int teamId) async {
    final response = await dio.get('/teams/$teamId/members');
    final members = (response.data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    return members
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final e = entry.value;
          return teamMemberModelFromMap(e, rank: index + 1);
        })
        .toList();
  }

  @override
  Future<TeamMemberModel> setMemberTeamPoints(
    int teamId,
    int memberUserId,
    int teamPoints,
  ) async {
    final response = await dio.put<dynamic>(
      '/teams/$teamId/members/$memberUserId/points',
      data: <String, dynamic>{'teamPoints': teamPoints},
    );
    final e = Map<String, dynamic>.from(response.data as Map);
    return teamMemberModelFromMap(
      e,
      rank: jsonParseInt(jsonPick(e, 'rank', 'Rank'), 1),
    );
  }

  @override
  Future<List<MemberBadgeAwardModel>> getMemberBadgeAwards(
    int teamId,
    int memberUserId,
  ) async {
    final response =
        await dio.get<dynamic>('/teams/$teamId/members/$memberUserId/badge-awards');
    final raw = response.data as List<dynamic>;
    return raw
        .map((e) => MemberBadgeAwardModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }

  @override
  Future<MemberBadgeAwardModel> grantMemberBadge(
    int teamId,
    int memberUserId,
    int badgeId,
  ) async {
    final response = await dio.post<dynamic>(
      '/teams/$teamId/members/$memberUserId/badges/$badgeId',
    );
    return MemberBadgeAwardModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  @override
  Future<void> revokeMemberBadgeAward(
    int teamId,
    int memberUserId,
    int userTeamBadgeId,
  ) async {
    await dio.delete<void>(
      '/teams/$teamId/members/$memberUserId/badge-awards/$userTeamBadgeId',
    );
  }

  @override
  Future<List<TeamModel>> discoverTeams(String query) async {
    final response = await dio.get('/teams');
    final allTeams = (response.data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final normalizedQuery = query.trim().toLowerCase();
    final filtered = normalizedQuery.isEmpty
        ? allTeams
        : allTeams.where((t) {
            final name = (t['name'] as String? ?? '').toLowerCase();
            return name.contains(normalizedQuery);
          }).toList();

    return filtered
        .map((e) => TeamModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> joinTeam(int teamId) async {
    await dio.post<void>(
      '/users/me/teams/$teamId/join-request',
      data: <String, dynamic>{},
    );
  }

  @override
  Future<List<MyPendingJoinRequestModel>> getMyPendingJoinRequests() async {
    try {
      final response = await dio.get<dynamic>('/users/me/join-requests');
      final data = response.data;
      if (data == null) return [];
      if (data is! List<dynamic>) {
        if (data is Map) {
          final inner = data['data'] ?? data['items'] ?? data['results'];
          if (inner is List<dynamic>) {
            return parseMyPendingJoinRequestsList(inner);
          }
        }
        return [];
      }
      return parseMyPendingJoinRequestsList(data);
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 404 || code == 405) {
        return [];
      }
      rethrow;
    }
  }

  @override
  Future<void> cancelMyJoinRequest(int teamId) async {
    await dio.delete<void>('/users/me/teams/$teamId/join-request');
  }

  @override
  Future<List<TeamJoinRequestModel>> getTeamJoinRequests(int teamId) async {
    final response = await dio.get('/teams/$teamId/join-requests');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => TeamJoinRequestModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }

  @override
  Future<void> approveJoinRequest(int teamId, int requestId) async {
    await dio.post<void>(
      '/teams/$teamId/join-requests/$requestId/approve',
    );
  }

  @override
  Future<void> rejectJoinRequest(int teamId, int requestId) async {
    await dio.post<void>(
      '/teams/$teamId/join-requests/$requestId/reject',
    );
  }

  @override
  Future<void> leaveTeam(int teamId) async {
    await dio.delete<void>('/teams/$teamId/members/me');
  }

  @override
  Future<void> removeTeamMember(int teamId, int memberUserId) async {
    await dio.delete<void>('/teams/$teamId/members/$memberUserId');
  }

  @override
  Future<TeamModel> createTeam({
    required String name,
    String? description,
    int? maxMembers,
  }) async {
    final response = await dio.post<dynamic>(
      '/teams',
      data: <String, dynamic>{
        'name': name.trim(),
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        'maxMembers': ?maxMembers,
      },
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    return teamModelFromDetailMap(data);
  }

  @override
  Future<void> deleteTeam(int teamId) async {
    await dio.delete<void>('/teams/$teamId');
  }

  @override
  Future<TeamModel> updateTeam(
    int teamId, {
    required String name,
    String? description,
    int? levelPointsMode,
    bool updateMaxMembers = false,
    int? maxMembers,
  }) async {
    final response = await dio.put<dynamic>(
      '/teams/$teamId',
      data: <String, dynamic>{
        'name': name.trim(),
        'description': (description == null || description.trim().isEmpty)
            ? null
            : description.trim(),
        'levelPointsMode': ?levelPointsMode,
        'updateMaxMembers': updateMaxMembers,
        if (updateMaxMembers) 'maxMembers': maxMembers,
      },
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    return teamModelFromDetailMap(data);
  }

  @override
  Future<void> createTeamLevel(
    int teamId, {
    String? name,
    required int requiredPoints,
    required int orderIndex,
  }) async {
    await dio.post<void>(
      '/teams/$teamId/gamification/levels',
      data: <String, dynamic>{
        'name': (name ?? '').trim(),
        'requiredPoints': requiredPoints,
        'orderIndex': orderIndex,
      },
    );
  }

  @override
  Future<void> updateTeamLevel(
    int teamId,
    int levelId, {
    String? name,
    required int requiredPoints,
    required int orderIndex,
  }) async {
    await dio.put<void>(
      '/teams/$teamId/gamification/levels/$levelId',
      data: <String, dynamic>{
        'name': (name ?? '').trim(),
        'requiredPoints': requiredPoints,
        'orderIndex': orderIndex,
      },
    );
  }

  @override
  Future<void> createTeamBadge(
    int teamId, {
    required String code,
    required String name,
    String? description,
    String? iconCode,
    String? conditionType,
    int? conditionValue,
  }) async {
    await dio.post<void>(
      '/teams/$teamId/gamification/badges',
      data: <String, dynamic>{
        'code': code.trim(),
        'name': name.trim(),
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        if (iconCode != null && iconCode.trim().isNotEmpty)
          'iconCode': iconCode.trim(),
        if (conditionType != null && conditionType.trim().isNotEmpty)
          'conditionType': conditionType.trim(),
        'conditionValue': ?conditionValue,
      },
    );
  }

  @override
  Future<void> updateTeamBadge(
    int teamId,
    int badgeId, {
    required String name,
    String? description,
    String? iconCode,
    String? conditionType,
    int? conditionValue,
  }) async {
    await dio.put<void>(
      '/teams/$teamId/gamification/badges/$badgeId',
      data: <String, dynamic>{
        'name': name.trim(),
        'description': (description == null || description.trim().isEmpty)
            ? null
            : description.trim(),
        'iconCode': (iconCode == null || iconCode.trim().isEmpty)
            ? null
            : iconCode.trim(),
        'conditionType': (conditionType == null || conditionType.trim().isEmpty)
            ? null
            : conditionType.trim(),
        'conditionValue': conditionValue,
      },
    );
  }

  @override
  Future<void> deleteTeamLevel(int teamId, int levelId) async {
    await dio.delete<void>('/teams/$teamId/gamification/levels/$levelId');
  }

  @override
  Future<void> deleteTeamBadge(int teamId, int badgeId) async {
    await dio.delete<void>('/teams/$teamId/gamification/badges/$badgeId');
  }
}
