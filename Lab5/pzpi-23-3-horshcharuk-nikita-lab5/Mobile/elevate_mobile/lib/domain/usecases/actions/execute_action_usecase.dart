import 'package:elevate_mobile/domain/entities/action/action_result.dart';
import 'package:elevate_mobile/domain/repositories/actions/actions_repository.dart';

class ExecuteActionUseCase {
  final ActionsRepository repository;

  ExecuteActionUseCase(this.repository);

  Future<ActionResult> call({
    required int teamId,
    required int userId,
    required int actionTypeId,
    required String sourceType,
    int? sourceUserId,
    String? comment,
    DateTime? occurredAt,
  }) {
    return repository.executeAction(
      teamId: teamId,
      userId: userId,
      actionTypeId: actionTypeId,
      sourceType: sourceType,
      sourceUserId: sourceUserId,
      comment: comment,
      occurredAt: occurredAt,
    );
  }
}