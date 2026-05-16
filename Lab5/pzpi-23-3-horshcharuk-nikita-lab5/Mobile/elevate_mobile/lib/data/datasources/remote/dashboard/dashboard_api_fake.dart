import 'package:elevate_mobile/data/datasources/remote/dashboard/dashboard_api.dart';
import 'package:elevate_mobile/data/models/dashboard/dashboard_model.dart';

class DashboardApiFake implements DashboardApi {
  @override
  Future<List<DashboardModel>> getDashboard() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return const [
      DashboardModel(
        teamId: 1,
        teamName: 'Backend Team',
        level: 5,
        points: 1250,
        rank: 12,
        currentXp: 600,
        nextLevelXp: 1000,
        atMaxTier: false,
        tierName: 'Legend',
        recentAchievements: [
          'First task completed',
          'Top 10 reached',
        ],
      ),
      DashboardModel(
        teamId: 2,
        teamName: 'Mobile Team',
        level: 3,
        points: 420,
        rank: 4,
        currentXp: 120,
        nextLevelXp: 300,
        atMaxTier: false,
        tierName: 'Champion',
        recentAchievements: ['5 day streak'],
      ),
    ];
  }
}