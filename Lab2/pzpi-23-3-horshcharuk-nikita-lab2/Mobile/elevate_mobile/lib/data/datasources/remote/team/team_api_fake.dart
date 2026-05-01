import 'package:elevate_mobile/data/datasources/remote/team/team_api.dart';
import 'package:elevate_mobile/data/models/team/core/team_model.dart';
import 'package:elevate_mobile/data/models/team/join/my_pending_join_request_model.dart';
import 'package:elevate_mobile/data/models/team/join/team_join_request_model.dart';
import 'package:elevate_mobile/data/models/team/members/member_badge_award_model.dart';
import 'package:elevate_mobile/data/models/team/members/team_member_model.dart';

class TeamApiFake implements TeamApi {

  static final List<MyPendingJoinRequestModel> _fakeMyPendingJoinRequests = [];
  static int _fakeJoinRequestId = 1;

  @override
  Future<List<TeamModel>> getMyTeams() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return const [
      TeamModel(
        id: 1,
        name: "Engineering",
        description: "Dev team",
        level: 5,
        tierName: 'Gold',
        points: 1500,
        createdByUserId: 1,
        levelPointsMode: 1,
        levelRows: [],
        badges: [],
        memberCount: 8,
      ),
      TeamModel(
        id: 2,
        name: "Marketing",
        description: "Marketing team",
        level: 3,
        tierName: 'Silver',
        points: 900,
        createdByUserId: 2,
        levelPointsMode: 1,
        levelRows: [],
        badges: [],
        memberCount: 4,
      ),
    ];
  }

  @override
  Future<TeamModel> getTeam(int id) async {
    await Future.delayed(const Duration(milliseconds: 400));

    return TeamModel(
      id: id,
      name: "Team $id",
      description: "Description",
      level: 4,
      tierName: 'Gold',
      points: 1200,
      levelPointsMode: 1,
      levelRows: const [],
      badges: const [],
      memberCount: 10,
      maxMembers: 20,
    );
  }

  @override
  Future<List<TeamMemberModel>> getTeamMembers(int teamId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    return List.generate(
      10,
          (index) => TeamMemberModel(
        id: index,
        name: "User ${index + 1}",
        level: 5 - (index % 5),
        tierName: 'Tier ${index % 3}',
        currentXp: 50 + index * 3,
        nextLevelXp: 200,
        points: 1200 - index * 50,
        rank: index + 1,
        teamRole: index == 0 ? 'Lead' : 'Member',
      ),
    );
  }

  @override
  Future<TeamMemberModel> setMemberTeamPoints(
    int teamId,
    int memberUserId,
    int teamPoints,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return TeamMemberModel(
      id: memberUserId,
      name: 'User $memberUserId',
      level: 1,
      tierName: 'Tier',
      currentXp: 0,
      nextLevelXp: 100,
      points: teamPoints,
      rank: 1,
      teamRole: 'Member',
    );
  }

  @override
  Future<List<MemberBadgeAwardModel>> getMemberBadgeAwards(
    int teamId,
    int memberUserId,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const [];
  }

  @override
  Future<MemberBadgeAwardModel> grantMemberBadge(
    int teamId,
    int memberUserId,
    int badgeId,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return MemberBadgeAwardModel(
      userTeamBadgeId: badgeId * 1000 + memberUserId,
      teamBadgeId: badgeId,
      badgeName: 'Badge $badgeId',
      awardedAt: DateTime.now(),
    );
  }

  @override
  Future<void> revokeMemberBadgeAward(
    int teamId,
    int memberUserId,
    int userTeamBadgeId,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<List<TeamModel>> discoverTeams(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final teams = const [
      TeamModel(
        id: 10,
        name: "Flutter Devs",
        description: "Mobile team",
        levelPointsMode: 1,
        levelRows: [],
        badges: [],
        memberCount: 5,
        maxMembers: 5,
      ),
      TeamModel(
        id: 11,
        name: "Backend Squad",
        description: "API team",
        levelPointsMode: 1,
        levelRows: [],
        badges: [],
        memberCount: 3,
        maxMembers: 12,
      ),
      TeamModel(
        id: 12,
        name: "Design Team",
        description: "UI/UX",
        levelPointsMode: 1,
        levelRows: [],
        badges: [],
        memberCount: 6,
      ),
      TeamModel(
        id: 13,
        name: "QA Team",
        description: "Testing",
        levelPointsMode: 1,
        levelRows: [],
        badges: [],
        memberCount: 2,
        maxMembers: 8,
      ),
      TeamModel(
        id: 14,
        name: "DevOps",
        description: "Infra",
        levelPointsMode: 1,
        levelRows: [],
        badges: [],
        memberCount: 10,
        maxMembers: 10,
      ),
    ];

    if (query.isEmpty) return teams;

    return teams
        .where((t) =>
        t.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<void> joinTeam(int teamId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (_fakeMyPendingJoinRequests.any((r) => r.teamId == teamId)) {
      return;
    }
    var name = 'Team $teamId';
    final discovered = await discoverTeams('');
    for (final t in discovered) {
      if (t.id == teamId) {
        name = t.name;
        break;
      }
    }
    _fakeMyPendingJoinRequests.add(
      MyPendingJoinRequestModel(
        id: _fakeJoinRequestId++,
        teamId: teamId,
        teamName: name,
        status: 'Pending',
        requestedAt: DateTime.now().toUtc(),
      ),
    );
  }

  @override
  Future<List<MyPendingJoinRequestModel>> getMyPendingJoinRequests() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final myTeamIds = (await getMyTeams()).map((t) => t.id).toSet();
    return _fakeMyPendingJoinRequests
        .where((r) => !myTeamIds.contains(r.teamId))
        .toList();
  }

  @override
  Future<void> cancelMyJoinRequest(int teamId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _fakeMyPendingJoinRequests.removeWhere((r) => r.teamId == teamId);
  }

  @override
  Future<void> leaveTeam(int teamId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> removeTeamMember(int teamId, int memberUserId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<List<TeamJoinRequestModel>> getTeamJoinRequests(int teamId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const [];
  }

  @override
  Future<void> approveJoinRequest(int teamId, int requestId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _fakeMyPendingJoinRequests.removeWhere(
      (r) => r.teamId == teamId || r.id == requestId,
    );
  }

  @override
  Future<void> rejectJoinRequest(int teamId, int requestId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _fakeMyPendingJoinRequests.removeWhere(
      (r) => r.teamId == teamId || r.id == requestId,
    );
  }

  @override
  Future<TeamModel> createTeam({
    required String name,
    String? description,
    int? maxMembers,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return TeamModel(
      id: 999,
      name: name,
      description: description,
      levelPointsMode: 1,
      levelRows: const [],
      badges: const [],
      createdByUserId: 1,
      memberCount: 1,
      maxMembers: maxMembers,
    );
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
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return TeamModel(
      id: teamId,
      name: name,
      description: description,
      levelPointsMode: levelPointsMode ?? 1,
      levelRows: const [],
      badges: const [],
      memberCount: 1,
      maxMembers: updateMaxMembers ? maxMembers : null,
    );
  }

  @override
  Future<void> deleteTeam(int teamId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> createTeamLevel(
    int teamId, {
    String? name,
    required int requiredPoints,
    required int orderIndex,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> updateTeamLevel(
    int teamId,
    int levelId, {
    String? name,
    required int requiredPoints,
    required int orderIndex,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
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
    await Future<void>.delayed(const Duration(milliseconds: 200));
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
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> deleteTeamLevel(int teamId, int levelId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> deleteTeamBadge(int teamId, int badgeId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}