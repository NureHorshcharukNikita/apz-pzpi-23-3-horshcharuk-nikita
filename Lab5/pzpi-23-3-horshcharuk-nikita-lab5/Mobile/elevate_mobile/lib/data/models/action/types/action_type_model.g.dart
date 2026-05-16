// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActionTypeModelImpl _$$ActionTypeModelImplFromJson(
  Map<String, dynamic> json,
) => _$ActionTypeModelImpl(
  id: (json['id'] as num).toInt(),
  teamId: (json['teamId'] as num).toInt(),
  code: json['code'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  defaultPoints: (json['defaultPoints'] as num).toInt(),
  category: json['category'] as String?,
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$$ActionTypeModelImplToJson(
  _$ActionTypeModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'teamId': instance.teamId,
  'code': instance.code,
  'name': instance.name,
  'description': instance.description,
  'defaultPoints': instance.defaultPoints,
  'category': instance.category,
  'isActive': instance.isActive,
};
