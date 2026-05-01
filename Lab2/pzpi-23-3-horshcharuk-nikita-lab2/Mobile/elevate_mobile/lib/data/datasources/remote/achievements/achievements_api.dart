import 'package:elevate_mobile/data/models/achievement/achievement_model.dart';

abstract class AchievementsApi {
  Future<List<AchievementModel>> getAchievements();
}