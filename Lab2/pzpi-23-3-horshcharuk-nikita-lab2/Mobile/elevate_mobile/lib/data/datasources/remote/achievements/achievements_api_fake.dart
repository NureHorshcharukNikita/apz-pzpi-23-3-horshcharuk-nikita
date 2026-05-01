import 'package:elevate_mobile/data/models/achievement/achievement_model.dart';
import 'package:elevate_mobile/data/datasources/remote/achievements/achievements_api.dart';

class AchievementsApiFake implements AchievementsApi {
  @override
  Future<List<AchievementModel>> getAchievements() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return List.generate(
      10,
          (index) => AchievementModel(
        id: "$index",
        title: "Achievement ${index + 1}",
        description: index.isEven ? "Optional badge note" : "",
        earned: index < 3,
        earnedAt: index < 3 ? DateTime.now() : null,
        teamId: index % 3 + 1,
        teamName: "Demo team ${index % 3 + 1}",
        requirement: "Reach ${100 + index * 10} team XP",
      ),
    );
  }
}