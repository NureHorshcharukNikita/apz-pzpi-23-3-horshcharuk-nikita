import 'package:elevate_mobile/data/datasources/remote/action/actions_api.dart';
import 'package:elevate_mobile/data/models/action/result/action_result_model.dart';
import 'package:elevate_mobile/data/models/action/types/action_type_model.dart';

class ActionsApiFake implements ActionsApi {
  @override
  Future<List<ActionTypeModel>> getTeamActionTypesForSetup(int teamId) async {
    return getTeamActionTypes(teamId);
  }

  @override
  Future<List<ActionTypeModel>> getTeamActionTypes(int teamId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    return [
      ActionTypeModel(
        id: 1,
        teamId: teamId,
        code: 'DEPLOY',
        name: 'Production Deployment',
        description: 'Deploy to production',
        defaultPoints: 50,
        category: 'Development',
        isActive: true,
      ),
      ActionTypeModel(
        id: 2,
        teamId: teamId,
        code: 'CODE_REVIEW',
        name: 'Code Review Hero',
        description: 'Complete code review',
        defaultPoints: 20,
        category: 'Development',
        isActive: true,
      ),
      ActionTypeModel(
        id: 3,
        teamId: teamId,
        code: 'HOTFIX',
        name: 'Critical Hotfix',
        description: 'Fix urgent issue',
        defaultPoints: 40,
        category: 'Support',
        isActive: true,
      ),
    ];
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
    await Future<void>.delayed(const Duration(milliseconds: 200));
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
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> deleteTeamActionType(int teamId, int actionTypeId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
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
    await Future.delayed(const Duration(milliseconds: 500));

    if (actionTypeId == 1) {
      return ActionResultModel(
        actionEventId: 101,
        userId: userId,
        teamId: teamId,
        pointsAwarded: 50,
        totalTeamPoints: 450,
        newTeamLevelName: 'Legend',
        newBadges: ['Sprint Hero'],
      );
    }

    if (actionTypeId == 2) {
      return ActionResultModel(
        actionEventId: 102,
        userId: userId,
        teamId: teamId,
        pointsAwarded: 20,
        totalTeamPoints: 270,
        newTeamLevelName: null,
        newBadges: [],
      );
    }

    return ActionResultModel(
      actionEventId: 103,
      userId: userId,
      teamId: teamId,
      pointsAwarded: 40,
      totalTeamPoints: 320,
      newTeamLevelName: 'Champion',
      newBadges: ['Hotfix Master'],
    );
  }
}