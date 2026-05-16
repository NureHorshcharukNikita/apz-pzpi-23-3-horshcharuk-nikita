import 'package:elevate_mobile/domain/entities/action/action_result.dart';
import 'package:elevate_mobile/domain/entities/action/action_type.dart';

abstract class ActionsRepository {
  Future<List<ActionType>> getTeamActionTypes(int teamId);

  Future<List<ActionType>> getTeamActionTypesForSetup(int teamId);

  Future<void> createTeamActionType(
    int teamId, {
    required String code,
    required String name,
    String? description,
    required int defaultPoints,
    String? category,
    bool isActive = true,
  });

  Future<void> updateTeamActionType(
    int teamId,
    int actionTypeId, {
    required String name,
    String? description,
    required int defaultPoints,
    String? category,
    required bool isActive,
  });

  Future<void> deleteTeamActionType(int teamId, int actionTypeId);

  Future<ActionResult> executeAction({
    required int teamId,
    required int userId,
    required int actionTypeId,
    required String sourceType,
    int? sourceUserId,
    String? comment,
    DateTime? occurredAt,
  });
}