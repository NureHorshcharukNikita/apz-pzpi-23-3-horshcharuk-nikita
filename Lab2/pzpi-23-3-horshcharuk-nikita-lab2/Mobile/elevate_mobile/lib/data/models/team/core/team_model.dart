// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:elevate_mobile/data/models/team/gamification/team_badge_model.dart';
import 'package:elevate_mobile/data/models/team/gamification/team_level_row_model.dart';
import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_points_mode.dart';

part 'team_model.freezed.dart';
part 'team_model.g.dart';

List<TeamBadgeModel> _teamBadgesFromJson(Object? json) {
  if (json is! List) return const [];
  return json
      .map((e) => TeamBadgeModel.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
}

int _levelPointsModeFromJson(Object? json) {
  if (json == null) return 1;
  if (json is int) return json;
  if (json is num) return json.toInt();
  return 1;
}

@freezed
class TeamModel with _$TeamModel {
  const TeamModel._();

  const factory TeamModel({
    required int id,
    required String name,
    String? description,
    int? level,
    String? tierName,
    int? points,
    int? createdByUserId,
    @JsonKey(fromJson: _levelPointsModeFromJson) @Default(1) int levelPointsMode,
    @Default([]) List<TeamLevelRowModel> levelRows,
    @JsonKey(fromJson: _teamBadgesFromJson, includeToJson: false)
        @Default([])
        List<TeamBadgeModel> badges,
    @Default(0) int memberCount,
    int? maxMembers,
  }) = _TeamModel;

  factory TeamModel.fromJson(Map<String, dynamic> json) =>
      _$TeamModelFromJson(json);

  Team toEntity() {
    return Team(
      id: id,
      name: name,
      description: description,
      level: level,
      tierName: tierName,
      points: points,
      levelThresholds: levelRows.isEmpty
          ? null
          : levelRows.map((e) => e.toThreshold()).toList(),
      createdByUserId: createdByUserId,
      badges: badges.isEmpty ? null : badges.map((e) => e.toEntity()).toList(),
      levelPointsMode: teamLevelPointsModeFromApiInt(levelPointsMode),
      memberCount: memberCount,
      maxMembers: maxMembers,
    );
  }
}