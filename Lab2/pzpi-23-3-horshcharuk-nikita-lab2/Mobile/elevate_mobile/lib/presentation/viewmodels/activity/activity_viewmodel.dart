import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:elevate_mobile/domain/usecases/activity/get_activity_usecase.dart';
import 'package:elevate_mobile/providers/activity/activity_provider.dart';
import 'package:elevate_mobile/presentation/states/activity/activity_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activityViewModelProvider =
    StateNotifierProvider.autoDispose<ActivityViewModel, ActivityState>(
  (ref) => ActivityViewModel(
    ref.read(getActivityUseCaseProvider),
  ),
);

class ActivityViewModel extends StateNotifier<ActivityState> {
  final GetActivityUseCase getActivity;

  int? _filterTeamId;

  int? get filterTeamId => _filterTeamId;

  ActivityViewModel(this.getActivity)
      : super(const ActivityState.initial()) {
    load();
  }

  void setFilterTeamId(int? teamId) {
    if (_filterTeamId == teamId) return;
    _filterTeamId = teamId;
    load();
  }

  Future<void> load() async {
    try {
      state = const ActivityState.loading();

      final data = await getActivity(teamId: _filterTeamId);

      state = ActivityState.loaded(data);
    } catch (e) {
      state = ActivityState.error(mapError(e));
    }
  }
}