import 'package:dio/dio.dart';
import 'package:elevate_mobile/data/models/achievement/achievement_model.dart';
import 'package:elevate_mobile/data/datasources/remote/achievements/achievements_api.dart';

class AchievementsApiImpl implements AchievementsApi {
  final Dio dio;

  AchievementsApiImpl(this.dio);

  @override
  Future<List<AchievementModel>> getAchievements() async {
    try {
      final response = await dio.get('/users/me/badges');
      final list = (response.data as List)
          .map(
            (e) => AchievementModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
      if (list.isNotEmpty) return list;
      return _achievementsFromDashboardFallback();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return _achievementsFromDashboardFallback();
      }
      rethrow;
    }
  }

  Future<List<AchievementModel>> _achievementsFromDashboardFallback() async {
    final response = await dio.get('/users/me/dashboard');
    final raw = response.data as List<dynamic>;
    final out = <AchievementModel>[];
    var seq = 0;
    for (final item in raw) {
      final m = Map<String, dynamic>.from(item as Map);
      final teamName = m['teamName'] as String? ?? 'Team';
      final recent = m['recentAchievements'];
      if (recent is! List) continue;
      for (final a in recent) {
        final title = a.toString().trim();
        if (title.isEmpty) continue;
        final teamId = m['teamId'];
        out.add(
          AchievementModel(
            id: 'dash-$seq',
            title: title,
            description: '',
            earned: true,
            earnedAt: null,
            teamId: teamId is int ? teamId : int.tryParse(teamId?.toString() ?? ''),
            teamName: teamName,
            requirement: null,
          ),
        );
        seq++;
      }
    }
    return out;
  }
}