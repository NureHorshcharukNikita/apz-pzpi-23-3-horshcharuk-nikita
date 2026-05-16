// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActionResultModelImpl _$$ActionResultModelImplFromJson(
  Map<String, dynamic> json,
) => _$ActionResultModelImpl(
  actionEventId: (json['actionEventId'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  teamId: (json['teamId'] as num).toInt(),
  pointsAwarded: (json['pointsAwarded'] as num).toInt(),
  totalTeamPoints: (json['totalTeamPoints'] as num).toInt(),
  newTeamLevelName: json['newTeamLevelName'] as String?,
  newBadges: (json['newBadges'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$$ActionResultModelImplToJson(
  _$ActionResultModelImpl instance,
) => <String, dynamic>{
  'actionEventId': instance.actionEventId,
  'userId': instance.userId,
  'teamId': instance.teamId,
  'pointsAwarded': instance.pointsAwarded,
  'totalTeamPoints': instance.totalTeamPoints,
  'newTeamLevelName': instance.newTeamLevelName,
  'newBadges': instance.newBadges,
};
