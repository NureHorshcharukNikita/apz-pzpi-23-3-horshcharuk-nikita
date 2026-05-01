import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:elevate_mobile/domain/entities/achievement/achievement.dart';

part 'achievement_model.freezed.dart';
part 'achievement_model.g.dart';

@freezed
class AchievementModel with _$AchievementModel {
  const AchievementModel._();

  const factory AchievementModel({
    required String id,
    required String title,
    required String description,
    required bool earned,
    DateTime? earnedAt,
    int? teamId,
    String? teamName,
    String? requirement,
  }) = _AchievementModel;

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      _$AchievementModelFromJson(json);

  Achievement toEntity() {
    return Achievement(
      id: id,
      title: title,
      description: description,
      earned: earned,
      earnedAt: earnedAt,
      teamId: teamId,
      teamName: teamName,
      requirement: requirement,
    );
  }
}