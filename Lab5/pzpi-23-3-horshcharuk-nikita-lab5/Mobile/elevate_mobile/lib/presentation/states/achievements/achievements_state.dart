import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:elevate_mobile/domain/entities/achievement/achievement.dart';

part 'achievements_state.freezed.dart';

@freezed
class AchievementsState with _$AchievementsState {
  const factory AchievementsState.initial() = _Initial;

  const factory AchievementsState.loading() = _Loading;

  const factory AchievementsState.loaded(
      List<Achievement> achievements,
      ) = _Loaded;

  const factory AchievementsState.error(String message) = _Error;
}