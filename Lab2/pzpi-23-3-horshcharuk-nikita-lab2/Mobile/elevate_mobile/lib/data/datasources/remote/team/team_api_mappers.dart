import 'package:elevate_mobile/core/utils/api_json_helpers.dart';
import 'package:elevate_mobile/data/models/team/core/team_model.dart';
import 'package:elevate_mobile/data/models/team/gamification/team_badge_model.dart';
import 'package:elevate_mobile/data/models/team/gamification/team_level_row_model.dart';
import 'package:elevate_mobile/data/models/team/join/my_pending_join_request_model.dart';
import 'package:elevate_mobile/data/models/team/members/team_member_model.dart';

TeamModel teamModelFromMyTeamsRow(Map<String, dynamic> e) {
  return TeamModel.fromJson({
    'id': jsonPick(e, 'teamId', 'TeamId'),
    'name': jsonPick(e, 'teamName', 'TeamName'),
    'description': null,
    'level': jsonPick(e, 'level', 'Level'),
    'tierName': jsonPick(e, 'teamLevel', 'TeamLevel'),
    'points': jsonPick(e, 'teamPoints', 'TeamPoints'),
    'createdByUserId': jsonPick(e, 'createdByUserId', 'CreatedByUserId'),
    'levelPointsMode': jsonPick(e, 'levelPointsMode', 'LevelPointsMode') ?? 1,
    'levelRows': const [],
    'memberCount': jsonPick(e, 'memberCount', 'MemberCount') ?? 0,
    'maxMembers': jsonPick(e, 'maxMembers', 'MaxMembers'),
  });
}

TeamModel teamModelFromDetailMap(Map<String, dynamic> data) {
  final levelsRaw =
      (jsonPick(data, 'levels', 'Levels') as List?) ?? const [];
  final levelRows = levelsRaw.map((raw) {
    final e = Map<String, dynamic>.from(raw as Map);
    return TeamLevelRowModel(
      id: jsonParseInt(jsonPick(e, 'id', 'Id'), 0),
      orderIndex: jsonParseInt(jsonPick(e, 'orderIndex', 'OrderIndex'), 0),
      requiredPoints:
          jsonParseInt(jsonPick(e, 'requiredPoints', 'RequiredPoints'), 0),
      name: '${jsonPick(e, 'name', 'Name') ?? ''}',
    );
  }).toList();

  final badgesRaw =
      (jsonPick(data, 'badges', 'Badges') as List?) ?? const [];
  final badgeModels = badgesRaw
      .map((raw) =>
          TeamBadgeModel.fromJson(Map<String, dynamic>.from(raw as Map)))
      .toList();

  final membersRaw = jsonPick(data, 'members', 'Members') as List?;
  final memberCount = jsonParseIntOpt(
        jsonPick(data, 'memberCount', 'MemberCount'),
      ) ??
      membersRaw?.length ??
      0;

  return TeamModel(
    id: jsonParseInt(jsonPick(data, 'id', 'Id'), 0),
    name: '${jsonPick(data, 'name', 'Name') ?? ''}',
    description: jsonPick(data, 'description', 'Description') as String?,
    level: null,
    tierName: null,
    points: null,
    createdByUserId:
        jsonParseIntOpt(jsonPick(data, 'createdByUserId', 'CreatedByUserId')),
    levelPointsMode: jsonParseInt(
      jsonPick(data, 'levelPointsMode', 'LevelPointsMode'),
      1,
    ),
    levelRows: levelRows,
    badges: badgeModels,
    memberCount: memberCount,
    maxMembers: jsonParseIntOpt(
      jsonPick(data, 'maxMembers', 'MaxMembers'),
    ),
  );
}

TeamMemberModel teamMemberModelFromMap(
  Map<String, dynamic> e, {
  required int rank,
}) {
  return TeamMemberModel.fromJson({
    'id': jsonPick(e, 'userId', 'UserId'),
    'name': jsonPick(e, 'fullName', 'FullName'),
    'level': jsonPick(e, 'level', 'Level'),
    'tierName': jsonPick(e, 'teamLevel', 'TeamLevel'),
    'currentXp': jsonPick(e, 'currentXp', 'CurrentXp'),
    'nextLevelXp': jsonPick(e, 'nextLevelXp', 'NextLevelXp'),
    'points': jsonPick(e, 'teamPoints', 'TeamPoints'),
    'rank': rank,
    'teamRole': jsonPick(e, 'teamRole', 'TeamRole'),
  });
}

List<MyPendingJoinRequestModel> parseMyPendingJoinRequestsList(
  List<dynamic> list,
) {
  final out = <MyPendingJoinRequestModel>[];
  for (final raw in list) {
    if (raw is! Map) continue;
    try {
      out.add(
        MyPendingJoinRequestModel.fromJson(
          Map<String, dynamic>.from(raw),
        ),
      );
    } catch (_) {
      continue;
    }
  }
  return out;
}
