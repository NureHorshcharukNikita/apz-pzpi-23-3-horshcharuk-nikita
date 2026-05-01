// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivityModelImpl _$$ActivityModelImplFromJson(Map<String, dynamic> json) =>
    _$ActivityModelImpl(
      id: json['id'] as String,
      teamId: (json['teamId'] as num).toInt(),
      teamName: json['teamName'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      points: (json['points'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$$ActivityModelImplToJson(_$ActivityModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'teamName': instance.teamName,
      'type': instance.type,
      'description': instance.description,
      'points': instance.points,
      'date': instance.date.toIso8601String(),
    };
