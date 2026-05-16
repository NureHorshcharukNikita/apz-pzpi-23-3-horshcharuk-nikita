import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/domain/usecases/team/discover_teams_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiscoverTeamsViewModel extends StateNotifier<AsyncValue<List<Team>>> {
  DiscoverTeamsViewModel(this._discover) : super(const AsyncValue.loading()) {
    search('');
  }

  final DiscoverTeamsUseCase _discover;

  String _lastQuery = '';

  Future<void> search(String query) async {
    _lastQuery = query;
    try {
      state = const AsyncValue.loading();

      final teams = await _discover(query);

      state = AsyncValue.data(teams);
    } catch (e) {
      state = AsyncValue.error(mapError(e), StackTrace.current);
    }
  }

  Future<void> refresh() async {
    await refreshWithQuery(_lastQuery);
  }

  Future<void> refreshWithQuery(String query) async {
    _lastQuery = query;
    try {
      final teams = await _discover(query);
      state = AsyncValue.data(teams);
    } catch (e) {
      state = AsyncValue.error(mapError(e), StackTrace.current);
    }
  }
}
