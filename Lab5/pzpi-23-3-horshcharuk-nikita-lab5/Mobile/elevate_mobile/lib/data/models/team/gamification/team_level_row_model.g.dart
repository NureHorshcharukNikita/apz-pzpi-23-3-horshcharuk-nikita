// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_level_row_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeamLevelRowModelImpl _$$TeamLevelRowModelImplFromJson(
  Map<String, dynamic> json,
) => _$TeamLevelRowModelImpl(
  id: (json['id'] as num).toInt(),
  orderIndex: (json['orderIndex'] as num).toInt(),
  requiredPoints: (json['requiredPoints'] as num).toInt(),
  name: json['name'] as String,
);

Map<String, dynamic> _$$TeamLevelRowModelImplToJson(
  _$TeamLevelRowModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orderIndex': instance.orderIndex,
  'requiredPoints': instance.requiredPoints,
  'name': instance.name,
};
