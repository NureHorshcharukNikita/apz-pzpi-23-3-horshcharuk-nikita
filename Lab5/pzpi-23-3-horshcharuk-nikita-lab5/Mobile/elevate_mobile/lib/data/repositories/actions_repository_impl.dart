import 'package:elevate_mobile/data/datasources/remote/action/actions_api.dart';
import 'package:elevate_mobile/domain/entities/action/action_result.dart';
import 'package:elevate_mobile/domain/entities/action/action_type.dart';
import 'package:elevate_mobile/domain/repositories/actions/actions_repository.dart';

class ActionsRepositoryImpl implements ActionsRepository {
  final ActionsApi api;

  ActionsRepositoryImpl(this.api);

  @override
  Future<List<ActionType>> getTeamActionTypes(int teamId) async {
    final result = await api.getTeamActionTypes(teamId);
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<ActionType>> getTeamActionTypesForSetup(int teamId) async {
    final result = await api.getTeamActionTypesForSetup(teamId);
    return result.map((e) => e.toEntity()).toList();
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
  }) =>
      api.createTeamActionType(
        teamId,
        code: code,
        name: name,
        description: description,
        defaultPoints: defaultPoints,
        category: category,
        isActive: isActive,
      );

  @override
  Future<void> updateTeamActionType(
    int teamId,
    int actionTypeId, {
    required String name,
    String? description,
    required int defaultPoints,
    String? category,
    required bool isActive,
  }) =>
      api.updateTeamActionType(
        teamId,
        actionTypeId,
        name: name,
        description: description,
        defaultPoints: defaultPoints,
        category: category,
        isActive: isActive,
      );

  @override
  Future<void> deleteTeamActionType(int teamId, int actionTypeId) =>
      api.deleteTeamActionType(teamId, actionTypeId);

  @override
  Future<ActionResult> executeAction({
    required int teamId,
    required int userId,
    required int actionTypeId,
    required String sourceType,
    int? sourceUserId,
    String? comment,
    DateTime? occurredAt,
  }) async {
    final result = await api.executeAction(
      teamId: teamId,
      userId: userId,
      actionTypeId: actionTypeId,
      sourceType: sourceType,
      sourceUserId: sourceUserId,
      comment: comment,
      occurredAt: occurredAt,
    );

    return result.toEntity();
  }
}