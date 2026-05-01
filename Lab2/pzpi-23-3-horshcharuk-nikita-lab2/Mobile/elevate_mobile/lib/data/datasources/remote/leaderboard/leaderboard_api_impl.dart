import 'package:dio/dio.dart';
import 'package:elevate_mobile/data/models/leaderboard/leaderboard_user_model.dart';
import 'package:elevate_mobile/data/datasources/remote/leaderboard/leaderboard_api.dart';

class LeaderboardApiImpl implements LeaderboardApi {
  final Dio dio;

  LeaderboardApiImpl(this.dio);

  @override
  Future<List<LeaderboardUserModel>> getLeaderboard(
      String period,
      ) async {
    final profileResponse = await dio.get('/users/me');
    final profileData = Map<String, dynamic>.from(profileResponse.data as Map);
    final teams = (profileData['teams'] as List?) ?? const [];
    if (teams.isEmpty) {
      return [];
    }

    final firstTeam = Map<String, dynamic>.from(teams.first as Map);
    final teamId = firstTeam['teamId'];
    final response = await dio.get('/teams/$teamId/leaderboard');

    return (response.data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map((e) => LeaderboardUserModel.fromJson({
          'position': e['rank'],
          'name': e['fullName'],
          'points': e['teamPoints'],
        }))
        .toList();
  }
}