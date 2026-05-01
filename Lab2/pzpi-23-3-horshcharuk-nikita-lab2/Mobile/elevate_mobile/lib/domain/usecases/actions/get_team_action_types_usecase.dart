import 'package:elevate_mobile/domain/entities/action/action_type.dart';
import 'package:elevate_mobile/domain/repositories/actions/actions_repository.dart';

class GetTeamActionTypesUseCase {
  final ActionsRepository repository;

  GetTeamActionTypesUseCase(this.repository);

  Future<List<ActionType>> call(int teamId) {
    return repository.getTeamActionTypes(teamId);
  }
}