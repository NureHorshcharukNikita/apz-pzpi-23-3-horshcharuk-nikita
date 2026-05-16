import 'package:elevate_mobile/domain/entities/achievement/achievement.dart';
import 'package:elevate_mobile/domain/repositories/achievements/achievements_repository.dart';

class GetAchievementsUseCase {
  final AchievementsRepository repository;

  GetAchievementsUseCase(this.repository);

  Future<List<Achievement>> call() {
    return repository.getAchievements();
  }
}