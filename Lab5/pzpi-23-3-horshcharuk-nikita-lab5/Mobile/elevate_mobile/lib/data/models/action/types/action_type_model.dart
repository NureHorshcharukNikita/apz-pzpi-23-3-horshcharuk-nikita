import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:elevate_mobile/domain/entities/action/action_type.dart';

part 'action_type_model.freezed.dart';
part 'action_type_model.g.dart';

@freezed
class ActionTypeModel with _$ActionTypeModel {
  const ActionTypeModel._();

  const factory ActionTypeModel({
    required int id,
    required int teamId,
    required String code,
    required String name,
    String? description,
    required int defaultPoints,
    String? category,
    required bool isActive,
  }) = _ActionTypeModel;

  factory ActionTypeModel.fromJson(Map<String, dynamic> json) =>
      _$ActionTypeModelFromJson(json);

  ActionType toEntity() {
    return ActionType(
      id: id,
      teamId: teamId,
      code: code,
      name: name,
      description: description,
      defaultPoints: defaultPoints,
      category: category,
      isActive: isActive,
    );
  }
}