// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardModelImpl _$$DashboardModelImplFromJson(Map<String, dynamic> json) =>
    _$DashboardModelImpl(
      teamId: _dashTeamId(json['teamId']),
      teamName: _dashName(json['teamName']),
      level: _dashLevel(json['level']),
      points: _dashXp(json['points']),
      rank: _dashIntMin1(json['rank']),
      currentXp: _dashXp(json['currentXp']),
      nextLevelXp: _dashNextLevelXp(json['nextLevelXp']),
      atMaxTier: json['atMaxTier'] == null
          ? false
          : _dashAtMaxTier(json['atMaxTier']),
      tierName: json['tierName'] as String?,
      recentAchievements: _dashAchievements(json['recentAchievements']),
    );

Map<String, dynamic> _$$DashboardModelImplToJson(
  _$DashboardModelImpl instance,
) => <String, dynamic>{
  'teamId': instance.teamId,
  'teamName': instance.teamName,
  'level': instance.level,
  'points': instance.points,
  'rank': instance.rank,
  'currentXp': instance.currentXp,
  'nextLevelXp': instance.nextLevelXp,
  'atMaxTier': instance.atMaxTier,
  'tierName': instance.tierName,
  'recentAchievements': instance.recentAchievements,
};
