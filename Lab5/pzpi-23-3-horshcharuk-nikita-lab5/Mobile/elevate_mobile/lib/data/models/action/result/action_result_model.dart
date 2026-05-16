import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:elevate_mobile/domain/entities/action/action_result.dart';

part 'action_result_model.freezed.dart';
part 'action_result_model.g.dart';

@freezed
class ActionResultModel with _$ActionResultModel {
  const ActionResultModel._();

  const factory ActionResultModel({
    required int actionEventId,
    required int userId,
    required int teamId,
    required int pointsAwarded,
    required int totalTeamPoints,
    String? newTeamLevelName,
    required List<String> newBadges,
  }) = _ActionResultModel;

  factory ActionResultModel.fromJson(Map<String, dynamic> json) =>
      _$ActionResultModelFromJson(json);

  ActionResult toEntity() {
    return ActionResult(
      actionEventId: actionEventId,
      userId: userId,
      teamId: teamId,
      pointsAwarded: pointsAwarded,
      totalTeamPoints: totalTeamPoints,
      newTeamLevelName: newTeamLevelName,
      newBadges: newBadges,
    );
  }
}