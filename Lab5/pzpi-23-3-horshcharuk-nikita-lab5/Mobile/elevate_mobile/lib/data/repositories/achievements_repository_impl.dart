import 'package:elevate_mobile/data/datasources/remote/achievements/achievements_api.dart';
import 'package:elevate_mobile/domain/entities/achievement/achievement.dart';
import 'package:elevate_mobile/domain/repositories/achievements/achievements_repository.dart';

class AchievementsRepositoryImpl
    implements AchievementsRepository {
  final AchievementsApi api;

  AchievementsRepositoryImpl(this.api);

  @override
  Future<List<Achievement>> getAchievements() async {
    final result = await api.getAchievements();

    return result.map((e) => e.toEntity()).toList();
  }
}