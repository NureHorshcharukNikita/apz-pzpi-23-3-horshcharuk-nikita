import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:elevate_mobile/data/datasources/remote/action/actions_api.dart';
import 'package:elevate_mobile/data/models/action/result/action_result_model.dart';
import 'package:elevate_mobile/data/models/action/types/action_type_model.dart';

class ActionsApiImpl implements ActionsApi {
  final Dio dio;

  ActionsApiImpl(this.dio);

  static void _normalizeActionResultMap(Map<String, dynamic> map) {
    void copyIfMissing(String camel, String pascal) {
      if (!map.containsKey(camel) && map.containsKey(pascal)) {
        map[camel] = map[pascal];
      }
    }

    copyIfMissing('actionEventId', 'ActionEventId');
    copyIfMissing('userId', 'UserId');
    copyIfMissing('teamId', 'TeamId');
    copyIfMissing('pointsAwarded', 'PointsAwarded');
    copyIfMissing('totalTeamPoints', 'TotalTeamPoints');
    copyIfMissing('newTeamLevelName', 'NewTeamLevelName');
    copyIfMissing('newBadges', 'NewBadges');

    String? pickLevel(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    final level = pickLevel(map['newTeamLevelName']);
    if (level != null) {
      map['newTeamLevelName'] = level;
    } else {
      map['newTeamLevelName'] = null;
    }

    final rawBadges = map['newBadges'];
    if (rawBadges == null) {
      map['newBadges'] = <String>[];
    } else if (rawBadges is List) {
      map['newBadges'] = rawBadges.map((e) {
        if (e is String) return e.trim();
        if (e is Map) {
          return '${e['badgeName'] ?? e['BadgeName'] ?? e['name'] ?? e['Name'] ?? ''}'
              .trim();
        }
        return e.toString().trim();
      }).where((s) => s.isNotEmpty).toList();
    } else {
      map['newBadges'] = <String>[];
    }
  }

  @override
  Future<List<ActionTypeModel>> getTeamActionTypes(int teamId) async {
    final response = await dio.get('/teams/$teamId/action-types');

    return (response.data as List)
        .map((e) => ActionTypeModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<List<ActionTypeModel>> getTeamActionTypesForSetup(int teamId) async {
    final response = await dio.get('/teams/$teamId/gamification/action-types');

    return (response.data as List)
        .map((e) => ActionTypeModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }

  @override
  Future<void> createTeamActionType(
    int teamId, {
    required String code,
    required String name,
    String? description,
    required int defaultPoints,
    String? category,
    bool isActive = true,
  }) async {
    await dio.post<void>(
      '/teams/$teamId/gamification/action-types',
      data: <String, dynamic>{
        'code': code.trim(),
        'name': name.trim(),
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        'defaultPoints': defaultPoints,
        if (category != null && category.trim().isNotEmpty)
          'category': category.trim(),
        'isActive': isActive,
      },
    );
  }

  @override
  Future<void> updateTeamActionType(
    int teamId,
    int actionTypeId, {
    required String name,
    String? description,
    required int defaultPoints,
    String? category,
    required bool isActive,
  }) async {
    await dio.put<void>(
      '/teams/$teamId/gamification/action-types/$actionTypeId',
      data: <String, dynamic>{
        'name': name.trim(),
        'description': (description == null || description.trim().isEmpty)
            ? null
            : description.trim(),
        'defaultPoints': defaultPoints,
        'category': (category == null || category.trim().isEmpty)
            ? null
            : category.trim(),
        'isActive': isActive,
      },
    );
  }

  @override
  Future<void> deleteTeamActionType(int teamId, int actionTypeId) async {
    await dio.delete<void>(
      '/teams/$teamId/gamification/action-types/$actionTypeId',
    );
  }

  @override
  Future<ActionResultModel> executeAction({
    required int teamId,
    required int userId,
    required int actionTypeId,
    required String sourceType,
    int? sourceUserId,
    String? comment,
    DateTime? occurredAt,
  }) async {
    final response = await dio.post(
      '/teams/$teamId/actions',
      data: {
        'userId': userId,
        'actionTypeId': actionTypeId,
        'sourceType': sourceType,
        'sourceUserId': sourceUserId,
        'comment': comment,
        'occurredAt': occurredAt?.toIso8601String(),
      },
    );

    final raw = response.data;
    final Object? decoded = raw is String ? jsonDecode(raw) : raw;
    if (decoded is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Action result is not a JSON object',
      );
    }

    final map = Map<String, dynamic>.from(decoded);
    _normalizeActionResultMap(map);
    return ActionResultModel.fromJson(map);
  }
}