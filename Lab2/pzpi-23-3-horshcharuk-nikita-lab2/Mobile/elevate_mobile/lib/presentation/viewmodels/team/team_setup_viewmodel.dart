import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/domain/entities/team/team_level_points_mode.dart';
import 'package:elevate_mobile/presentation/viewmodels/actions/actions_viewmodel.dart';
import 'package:elevate_mobile/presentation/viewmodels/dashboard/dashboard_viewmodel.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/my_teams_viewmodel.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/team_details_viewmodel.dart';
import 'package:elevate_mobile/providers/actions/actions_provider.dart';
import 'package:elevate_mobile/providers/team/team_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamSetupUiState {
  final bool teamOperationBusy;

  const TeamSetupUiState({this.teamOperationBusy = false});

  TeamSetupUiState copyWith({bool? teamOperationBusy}) {
    return TeamSetupUiState(
      teamOperationBusy: teamOperationBusy ?? this.teamOperationBusy,
    );
  }
}

final teamSetupViewModelProvider =
    StateNotifierProvider.family<TeamSetupViewModel, TeamSetupUiState, int>(
  (ref, teamId) => TeamSetupViewModel(ref, teamId),
);

class TeamSetupViewModel extends StateNotifier<TeamSetupUiState> {
  TeamSetupViewModel(this.ref, this.teamId) : super(const TeamSetupUiState());

  final Ref ref;
  final int teamId;

  Future<void> refresh({bool reloadActionTypes = true}) async {
    await ref
        .read(teamDetailsViewModelProvider(teamId).notifier)
        .load(showLoadingIndicator: false);

    ref.invalidate(myPendingJoinRequestsProvider);
    final futures = <Future<void>>[
      Future.wait<void>([
        ref.read(myTeamsViewModelProvider.notifier).load(
              showLoadingIndicator: false,
            ),
        ref.read(discoverTeamsProvider.notifier).refresh(),
        ref.read(dashboardViewModelProvider.notifier).load(
              showLoadingIndicator: false,
            ),
      ]),
    ];

    if (reloadActionTypes) {
      ref.invalidate(teamSetupActionTypesProvider(teamId));
      ref.invalidate(actionsViewModelProvider(teamId));
      futures.insert(
        0,
        ref.read(teamSetupActionTypesProvider(teamId).future),
      );
    }

    await Future.wait<void>(futures);
  }

  /// Returns validation or API error message; `null` means success.
  Future<String?> saveTeam({
    required String name,
    required String descriptionTrim,
    required bool unlimitedMembers,
    required String maxMembersText,
  }) async {
    if (name.trim().isEmpty) {
      return 'Team name is required';
    }

    int? maxCap;
    if (!unlimitedMembers) {
      final cap = int.tryParse(maxMembersText.trim());
      if (cap == null || cap < 1) {
        return 'Enter max members (1 or more), or enable unlimited.';
      }
      maxCap = cap;
    }

    final teamNow = ref
        .read(teamDetailsViewModelProvider(teamId))
        .maybeWhen(loaded: (t) => t, orElse: () => null);
    if (teamNow != null &&
        maxCap != null &&
        teamNow.memberCount > maxCap) {
      return 'Max cannot be below current members (${teamNow.memberCount}).';
    }

    state = state.copyWith(teamOperationBusy: true);
    try {
      await ref.read(teamRepositoryProvider).updateTeam(
            teamId,
            name: name.trim(),
            description: descriptionTrim.isEmpty ? null : descriptionTrim,
            updateMaxMembers: true,
            maxMembers: maxCap,
          );
      await refresh();
      return null;
    } catch (e) {
      return mapError(e);
    } finally {
      state = state.copyWith(teamOperationBusy: false);
    }
  }

  Future<String?> saveLevelPointsMode(Team team, TeamLevelPointsMode mode) async {
    if (team.levelPointsMode == mode) return null;
    state = state.copyWith(teamOperationBusy: true);
    try {
      await ref.read(teamRepositoryProvider).updateTeam(
            teamId,
            name: team.name,
            description: team.description,
            levelPointsMode: teamLevelPointsModeToApiInt(mode),
          );
      await refresh(reloadActionTypes: false);
      return null;
    } catch (e) {
      return mapError(e);
    } finally {
      state = state.copyWith(teamOperationBusy: false);
    }
  }

  Future<String?> deleteTeamLevel(int levelId) async {
    try {
      await ref.read(teamRepositoryProvider).deleteTeamLevel(teamId, levelId);
      await refresh();
      return null;
    } catch (e) {
      return mapError(e);
    }
  }

  Future<String?> deleteTeamBadge(int badgeId) async {
    try {
      await ref.read(teamRepositoryProvider).deleteTeamBadge(teamId, badgeId);
      await refresh();
      return null;
    } catch (e) {
      return mapError(e);
    }
  }

  Future<String?> deleteActionType(int actionTypeId) async {
    try {
      await ref
          .read(actionsRepositoryProvider)
          .deleteTeamActionType(teamId, actionTypeId);
      await refresh();
      return null;
    } catch (e) {
      return mapError(e);
    }
  }

  Future<String?> updateTeamLevel({
    required int levelId,
    required int orderIndex,
    required int requiredPoints,
    String? name,
  }) async {
    try {
      await ref.read(teamRepositoryProvider).updateTeamLevel(
            teamId,
            levelId,
            name: name,
            requiredPoints: requiredPoints,
            orderIndex: orderIndex,
          );
      await refresh(reloadActionTypes: false);
      return null;
    } catch (e) {
      return mapError(e);
    }
  }

  Future<String?> updateTeamBadge({
    required int badgeId,
    required String name,
    String? description,
    String? iconCode,
    required String conditionType,
    required int conditionValue,
  }) async {
    try {
      await ref.read(teamRepositoryProvider).updateTeamBadge(
            teamId,
            badgeId,
            name: name,
            description: description,
            iconCode: iconCode,
            conditionType: conditionType,
            conditionValue: conditionValue,
          );
      await refresh();
      return null;
    } catch (e) {
      return mapError(e);
    }
  }

  Future<String?> updateActionType({
    required int actionTypeId,
    required String name,
    String? description,
    required int defaultPoints,
    String? category,
    required bool isActive,
  }) async {
    try {
      await ref.read(actionsRepositoryProvider).updateTeamActionType(
            teamId,
            actionTypeId,
            name: name,
            description: description,
            defaultPoints: defaultPoints,
            category: category,
            isActive: isActive,
          );
      await refresh();
      return null;
    } catch (e) {
      return mapError(e);
    }
  }
}
