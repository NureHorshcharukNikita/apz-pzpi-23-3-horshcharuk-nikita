// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeamModelImpl _$$TeamModelImplFromJson(Map<String, dynamic> json) =>
    _$TeamModelImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      level: (json['level'] as num?)?.toInt(),
      tierName: json['tierName'] as String?,
      points: (json['points'] as num?)?.toInt(),
      createdByUserId: (json['createdByUserId'] as num?)?.toInt(),
      levelPointsMode: json['levelPointsMode'] == null
          ? 1
          : _levelPointsModeFromJson(json['levelPointsMode']),
      levelRows:
          (json['levelRows'] as List<dynamic>?)
              ?.map(
                (e) => TeamLevelRowModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      badges: json['badges'] == null
          ? const []
          : _teamBadgesFromJson(json['badges']),
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      maxMembers: (json['maxMembers'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$TeamModelImplToJson(_$TeamModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'level': instance.level,
      'tierName': instance.tierName,
      'points': instance.points,
      'createdByUserId': instance.createdByUserId,
      'levelPointsMode': instance.levelPointsMode,
      'levelRows': instance.levelRows,
      'memberCount': instance.memberCount,
      'maxMembers': instance.maxMembers,
    };
