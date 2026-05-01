import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:elevate_mobile/domain/entities/activity/activity.dart';

part 'activity_model.freezed.dart';
part 'activity_model.g.dart';

@freezed
class ActivityModel with _$ActivityModel {
  const ActivityModel._();

  const factory ActivityModel({
    required String id,
    required int teamId,
    required String teamName,
    required String type,
    required String description,
    required int points,
    required DateTime date,
  }) = _ActivityModel;

  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);

  Activity toEntity() {
    return Activity(
      id: id,
      teamId: teamId,
      teamName: teamName,
      type: type,
      description: description,
      points: points,
      date: date,
    );
  }
}