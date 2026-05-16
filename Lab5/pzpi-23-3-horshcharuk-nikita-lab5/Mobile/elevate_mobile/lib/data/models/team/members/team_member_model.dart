// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:elevate_mobile/domain/entities/team/team_member.dart';

part 'team_member_model.freezed.dart';
part 'team_member_model.g.dart';

int _parseMemberInt(dynamic value, int fallback) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return fallback;
}

int _parseMemberId(dynamic value) => _parseMemberInt(value, 0);

int _parseMemberLevel(dynamic value) {
  final n = _parseMemberInt(value, 1);
  return n < 1 ? 1 : n;
}

int _parseMemberXp(dynamic value) => _parseMemberInt(value, 0);

int _parseMemberNextXp(dynamic value) {
  final n = _parseMemberInt(value, 1);
  return n < 1 ? 1 : n;
}

int _parseMemberRank(dynamic value) {
  final n = _parseMemberInt(value, 1);
  return n < 1 ? 1 : n;
}

String _parseMemberName(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  return value.toString();
}

String _parseTeamRole(dynamic value) {
  if (value == null) return 'Member';
  if (value is String) {
    final t = value.trim();
    return t.isEmpty ? 'Member' : t;
  }
  return value.toString();
}

@freezed
class TeamMemberModel with _$TeamMemberModel {
  const TeamMemberModel._();

  const factory TeamMemberModel({
    @JsonKey(fromJson: _parseMemberId) required int id,
    @JsonKey(fromJson: _parseMemberName) required String name,
    @JsonKey(fromJson: _parseMemberLevel) required int level,
    String? tierName,
    @JsonKey(fromJson: _parseMemberXp) required int currentXp,
    @JsonKey(fromJson: _parseMemberNextXp) required int nextLevelXp,
    @JsonKey(fromJson: _parseMemberXp) required int points,
    @JsonKey(fromJson: _parseMemberRank) required int rank,
    @JsonKey(fromJson: _parseTeamRole) @Default('Member') String teamRole,
  }) = _TeamMemberModel;

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) =>
      _$TeamMemberModelFromJson(json);

  TeamMember toEntity() {
    return TeamMember(
      id: id,
      name: name,
      level: level,
      tierName: tierName,
      currentXp: currentXp,
      nextLevelXp: nextLevelXp,
      points: points,
      rank: rank,
      teamRole: teamRole,
    );
  }
}