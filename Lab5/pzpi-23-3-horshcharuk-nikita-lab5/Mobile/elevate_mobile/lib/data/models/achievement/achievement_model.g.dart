// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AchievementModelImpl _$$AchievementModelImplFromJson(
  Map<String, dynamic> json,
) => _$AchievementModelImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  earned: json['earned'] as bool,
  earnedAt: json['earnedAt'] == null
      ? null
      : DateTime.parse(json['earnedAt'] as String),
  teamId: (json['teamId'] as num?)?.toInt(),
  teamName: json['teamName'] as String?,
  requirement: json['requirement'] as String?,
);

Map<String, dynamic> _$$AchievementModelImplToJson(
  _$AchievementModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'earned': instance.earned,
  'earnedAt': instance.earnedAt?.toIso8601String(),
  'teamId': instance.teamId,
  'teamName': instance.teamName,
  'requirement': instance.requirement,
};
