// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:elevate_mobile/domain/entities/dashboard/dashboard.dart';

part 'dashboard_model.freezed.dart';
part 'dashboard_model.g.dart';

int _dashInt(dynamic v, int fallback) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return fallback;
}

int _dashIntMin1(dynamic v) {
  final n = _dashInt(v, 1);
  return n < 1 ? 1 : n;
}

int _dashXp(dynamic v) => _dashInt(v, 0);

int _dashTeamId(dynamic v) => _dashInt(v, 0);

int _dashLevel(dynamic v) => _dashInt(v, 0);

int _dashNextLevelXp(dynamic v) => _dashInt(v, 0);

bool _dashAtMaxTier(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0;
  return false;
}

String _dashName(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  return v.toString();
}

List<String> _dashAchievements(dynamic v) {
  if (v == null) return const [];
  if (v is! List) return const [];
  return v.map((e) => e is String ? e : '$e').toList();
}

@freezed
class DashboardModel with _$DashboardModel {
  const DashboardModel._();

  const factory DashboardModel({
    @JsonKey(fromJson: _dashTeamId) required int teamId,
    @JsonKey(fromJson: _dashName) required String teamName,
    @JsonKey(fromJson: _dashLevel) required int level,
    @JsonKey(fromJson: _dashXp) required int points,
    @JsonKey(fromJson: _dashIntMin1) required int rank,
    @JsonKey(fromJson: _dashXp) required int currentXp,
    @JsonKey(fromJson: _dashNextLevelXp) required int nextLevelXp,
    @JsonKey(fromJson: _dashAtMaxTier) @Default(false) bool atMaxTier,
    String? tierName,
    @JsonKey(fromJson: _dashAchievements) required List<String> recentAchievements,
  }) = _DashboardModel;

  factory DashboardModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardModelFromJson(json);

  Dashboard toEntity() {
    return Dashboard(
      teamId: teamId,
      teamName: teamName,
      level: level,
      points: points,
      rank: rank,
      currentXp: currentXp,
      nextLevelXp: nextLevelXp,
      atMaxTier: atMaxTier,
      tierName: tierName,
      recentAchievements: recentAchievements,
    );
  }
}