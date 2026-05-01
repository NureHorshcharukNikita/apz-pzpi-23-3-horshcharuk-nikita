import 'package:elevate_mobile/data/models/action/result/action_result_model.dart';
import 'package:elevate_mobile/data/models/action/types/action_type_model.dart';

abstract class ActionsApi {
  Future<List<ActionTypeModel>> getTeamActionTypes(int teamId);

  Future<List<ActionTypeModel>> getTeamActionTypesForSetup(int teamId);

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

  Future<ActionResultModel> executeAction({
    required int teamId,
    required int userId,
    required int actionTypeId,
    required String sourceType,
    int? sourceUserId,
    String? comment,
    DateTime? occurredAt,
  });
}