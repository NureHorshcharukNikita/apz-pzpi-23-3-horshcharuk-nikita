// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeamMemberModelImpl _$$TeamMemberModelImplFromJson(
  Map<String, dynamic> json,
) => _$TeamMemberModelImpl(
  id: _parseMemberId(json['id']),
  name: _parseMemberName(json['name']),
  level: _parseMemberLevel(json['level']),
  tierName: json['tierName'] as String?,
  currentXp: _parseMemberXp(json['currentXp']),
  nextLevelXp: _parseMemberNextXp(json['nextLevelXp']),
  points: _parseMemberXp(json['points']),
  rank: _parseMemberRank(json['rank']),
  teamRole: json['teamRole'] == null
      ? 'Member'
      : _parseTeamRole(json['teamRole']),
);

Map<String, dynamic> _$$TeamMemberModelImplToJson(
  _$TeamMemberModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'level': instance.level,
  'tierName': instance.tierName,
  'currentXp': instance.currentXp,
  'nextLevelXp': instance.nextLevelXp,
  'points': instance.points,
  'rank': instance.rank,
  'teamRole': instance.teamRole,
};
