import 'package:elevate_mobile/domain/entities/team/my_pending_join_request.dart';
import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/domain/entities/team/team_join_request.dart';
import 'package:elevate_mobile/domain/usecases/team/cancel_my_join_request_usecase.dart';
import 'package:elevate_mobile/domain/usecases/team/get_my_pending_join_requests_usecase.dart';
import 'package:elevate_mobile/domain/usecases/team/approve_join_request_usecase.dart';
import 'package:elevate_mobile/domain/usecases/team/create_team_usecase.dart';
import 'package:elevate_mobile/domain/usecases/team/delete_team_usecase.dart';
import 'package:elevate_mobile/domain/usecases/team/discover_teams_usecase.dart';
import 'package:elevate_mobile/domain/usecases/team/get_team_join_requests_usecase.dart';
import 'package:elevate_mobile/domain/usecases/team/get_team_members_usecase.dart';
import 'package:elevate_mobile/domain/usecases/team/join_team_usecase.dart';
import 'package:elevate_mobile/domain/usecases/team/kick_team_member_usecase.dart';
import 'package:elevate_mobile/domain/usecases/team/leave_team_usecase.dart';
import 'package:elevate_mobile/domain/usecases/team/reject_join_request_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elevate_mobile/core/config/app_config.dart';
import 'package:elevate_mobile/providers/core/dio_provider.dart';
import 'package:elevate_mobile/data/datasources/remote/team/team_api.dart';
import 'package:elevate_mobile/data/datasources/remote/team/team_api_fake.dart';
import 'package:elevate_mobile/data/datasources/remote/team/team_api_impl.dart';
import 'package:elevate_mobile/data/repositories/team_repository_impl.dart';
import 'package:elevate_mobile/domain/repositories/team/team_repository.dart';
import 'package:elevate_mobile/domain/usecases/team/get_my_teams_usecase.dart';
import 'package:elevate_mobile/domain/usecases/team/get_team_details_usecase.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/discover_teams_viewmodel.dart';

final teamApiProvider = Provider<TeamApi>((ref) {
  if (AppConfig.useMockServices) {
    return TeamApiFake();
  }

  return TeamApiImpl(ref.read(dioProvider));
});

final teamRepositoryProvider =
Provider<TeamRepository>((ref) {
  return TeamRepositoryImpl(
    ref.read(teamApiProvider),
  );
});

final getMyTeamsUseCaseProvider =
Provider<GetMyTeamsUseCase>((ref) {
  return GetMyTeamsUseCase(
    ref.read(teamRepositoryProvider),
  );
});

final getTeamDetailsUseCaseProvider =
Provider<GetTeamDetailsUseCase>((ref) {
  return GetTeamDetailsUseCase(
    ref.read(teamRepositoryProvider),
  );
});

final getTeamMembersUseCaseProvider =
Provider<GetTeamMembersUseCase>((ref) {
  return GetTeamMembersUseCase(
    ref.read(teamRepositoryProvider),
  );
});

final discoverTeamsUseCaseProvider  =
Provider<DiscoverTeamsUseCase>((ref) {
  return DiscoverTeamsUseCase(
    ref.read(teamRepositoryProvider),
  );
});

final discoverTeamsProvider =
    StateNotifierProvider<DiscoverTeamsViewModel, AsyncValue<List<Team>>>(
  (ref) => DiscoverTeamsViewModel(
    ref.read(discoverTeamsUseCaseProvider),
  ),
);

final joinTeamUseCaseProvider = Provider<JoinTeamUseCase>((ref) {
  return JoinTeamUseCase(ref.read(teamRepositoryProvider));
});

final getMyPendingJoinRequestsUseCaseProvider =
    Provider<GetMyPendingJoinRequestsUseCase>((ref) {
  return GetMyPendingJoinRequestsUseCase(ref.read(teamRepositoryProvider));
});

final cancelMyJoinRequestUseCaseProvider =
    Provider<CancelMyJoinRequestUseCase>((ref) {
  return CancelMyJoinRequestUseCase(ref.read(teamRepositoryProvider));
});

final myPendingJoinRequestsProvider =
    FutureProvider.autoDispose<List<MyPendingJoinRequest>>((ref) async {
  final uc = ref.read(getMyPendingJoinRequestsUseCaseProvider);
  return uc.call();
});

final leaveTeamUseCaseProvider = Provider<LeaveTeamUseCase>((ref) {
  return LeaveTeamUseCase(ref.read(teamRepositoryProvider));
});

final kickTeamMemberUseCaseProvider = Provider<KickTeamMemberUseCase>((ref) {
  return KickTeamMemberUseCase(ref.read(teamRepositoryProvider));
});

final getTeamJoinRequestsUseCaseProvider =
    Provider<GetTeamJoinRequestsUseCase>((ref) {
  return GetTeamJoinRequestsUseCase(ref.read(teamRepositoryProvider));
});

final approveJoinRequestUseCaseProvider =
    Provider<ApproveJoinRequestUseCase>((ref) {
  return ApproveJoinRequestUseCase(ref.read(teamRepositoryProvider));
});

final rejectJoinRequestUseCaseProvider =
    Provider<RejectJoinRequestUseCase>((ref) {
  return RejectJoinRequestUseCase(ref.read(teamRepositoryProvider));
});

final teamJoinRequestsProvider = FutureProvider.autoDispose
    .family<List<TeamJoinRequest>, int>((ref, teamId) async {
  final uc = ref.read(getTeamJoinRequestsUseCaseProvider);
  return uc.call(teamId);
});

final createTeamUseCaseProvider = Provider<CreateTeamUseCase>((ref) {
  return CreateTeamUseCase(ref.read(teamRepositoryProvider));
});

final deleteTeamUseCaseProvider = Provider<DeleteTeamUseCase>((ref) {
  return DeleteTeamUseCase(ref.read(teamRepositoryProvider));
});