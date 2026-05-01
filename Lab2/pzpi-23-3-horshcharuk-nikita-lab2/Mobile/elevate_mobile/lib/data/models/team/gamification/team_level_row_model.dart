import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_threshold.dart';

part 'team_level_row_model.freezed.dart';
part 'team_level_row_model.g.dart';

@freezed
class TeamLevelRowModel with _$TeamLevelRowModel {
  const factory TeamLevelRowModel({
    required int id,
    required int orderIndex,
    required int requiredPoints,
    required String name,
  }) = _TeamLevelRowModel;

  factory TeamLevelRowModel.fromJson(Map<String, dynamic> json) =>
      _$TeamLevelRowModelFromJson(json);
}

extension TeamLevelRowModelX on TeamLevelRowModel {
  TeamLevelThreshold toThreshold() => TeamLevelThreshold(
        id: id,
        orderIndex: orderIndex,
        requiredPoints: requiredPoints,
        name: name,
      );
}
