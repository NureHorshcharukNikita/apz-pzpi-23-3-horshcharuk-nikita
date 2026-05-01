// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeaderboardUserModelImpl _$$LeaderboardUserModelImplFromJson(
  Map<String, dynamic> json,
) => _$LeaderboardUserModelImpl(
  position: (json['position'] as num).toInt(),
  name: json['name'] as String,
  points: (json['points'] as num).toInt(),
);

Map<String, dynamic> _$$LeaderboardUserModelImplToJson(
  _$LeaderboardUserModelImpl instance,
) => <String, dynamic>{
  'position': instance.position,
  'name': instance.name,
  'points': instance.points,
};
