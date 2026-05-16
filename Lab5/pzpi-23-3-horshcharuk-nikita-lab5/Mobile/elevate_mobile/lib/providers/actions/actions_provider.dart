import 'package:elevate_mobile/data/datasources/remote/action/actions_api.dart';
import 'package:elevate_mobile/data/datasources/remote/action/actions_api_fake.dart';
import 'package:elevate_mobile/data/datasources/remote/action/actions_api_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elevate_mobile/core/config/app_config.dart';
import 'package:elevate_mobile/data/repositories/actions_repository_impl.dart';
import 'package:elevate_mobile/domain/repositories/actions/actions_repository.dart';
import 'package:elevate_mobile/domain/usecases/actions/execute_action_usecase.dart';
import 'package:elevate_mobile/domain/entities/action/action_type.dart';
import 'package:elevate_mobile/domain/usecases/actions/get_team_action_types_usecase.dart';
import 'package:elevate_mobile/providers/core/dio_provider.dart';

final actionsApiProvider = Provider<ActionsApi>((ref) {
  if (AppConfig.useMockServices) {
    return ActionsApiFake();
  }

  return ActionsApiImpl(ref.read(dioProvider));
});

final actionsRepositoryProvider = Provider<ActionsRepository>((ref) {
  return ActionsRepositoryImpl(
    ref.read(actionsApiProvider),
  );
});

final getTeamActionTypesUseCaseProvider =
Provider<GetTeamActionTypesUseCase>((ref) {
  return GetTeamActionTypesUseCase(
    ref.read(actionsRepositoryProvider),
  );
});

final teamSetupActionTypesProvider =
    FutureProvider.autoDispose.family<List<ActionType>, int>((ref, teamId) async {
  final repo = ref.read(actionsRepositoryProvider);
  return repo.getTeamActionTypesForSetup(teamId);
});

final executeActionUseCaseProvider = Provider<ExecuteActionUseCase>((ref) {
  return ExecuteActionUseCase(
    ref.read(actionsRepositoryProvider),
  );
});