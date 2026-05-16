import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:elevate_mobile/domain/entities/achievement/achievement.dart';
import 'package:elevate_mobile/domain/usecases/achievements/get_achievements_usecase.dart';
import 'package:elevate_mobile/providers/achievements/achievements_provider.dart';
import 'package:elevate_mobile/presentation/states/achievements/achievements_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final achievementsViewModelProvider = StateNotifierProvider.autoDispose<
    AchievementsViewModel,
    AchievementsState>(
  (ref) => AchievementsViewModel(
    ref.read(getAchievementsUseCaseProvider),
  ),
);

class AchievementsViewModel
    extends StateNotifier<AchievementsState> {
  final GetAchievementsUseCase getAchievements;

  List<Achievement>? _all;
  int? _filterTeamId;

  int? get filterTeamId => _filterTeamId;

  AchievementsViewModel(this.getAchievements)
      : super(const AchievementsState.initial()) {
    load();
  }

  void setFilterTeamId(int? teamId) {
    if (_filterTeamId == teamId) return;
    _filterTeamId = teamId;
    _emitFiltered();
  }

  void _emitFiltered() {
    final all = _all;
    if (all == null) return;
    final filtered = _filterTeamId == null
        ? all
        : all.where((a) => a.teamId == _filterTeamId).toList();
    state = AchievementsState.loaded(filtered);
  }

  Future<void> load() async {
    try {
      state = const AchievementsState.loading();

      final data = await getAchievements();
      _all = data;
      _emitFiltered();
    } catch (e) {
      state = AchievementsState.error(mapError(e));
    }
  }
}