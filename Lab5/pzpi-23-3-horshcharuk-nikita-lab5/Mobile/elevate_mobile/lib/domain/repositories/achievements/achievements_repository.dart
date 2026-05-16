import 'package:elevate_mobile/domain/entities/achievement/achievement.dart';

abstract class AchievementsRepository {
  Future<List<Achievement>> getAchievements();
}