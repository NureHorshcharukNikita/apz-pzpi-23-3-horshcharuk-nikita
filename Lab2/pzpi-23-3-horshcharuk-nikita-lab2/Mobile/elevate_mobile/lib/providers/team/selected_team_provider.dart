import 'package:elevate_mobile/data/datasources/local/auth_preferences.dart';
import 'package:elevate_mobile/domain/entities/dashboard/dashboard.dart';
import 'package:elevate_mobile/providers/auth/auth_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedTeamIdProvider =
    StateNotifierProvider<SelectedTeamNotifier, int?>((ref) {
  return SelectedTeamNotifier(ref.read(authPreferencesProvider));
});

class SelectedTeamNotifier extends StateNotifier<int?> {
  SelectedTeamNotifier(this._prefs) : super(null) {
    state = _prefs.getSelectedTeamId();
  }

  final AuthPreferences _prefs;

  Future<void> setTeamId(int teamId) async {
    state = teamId;
    await _prefs.setSelectedTeamId(teamId);
  }

  Future<void> ensureValidSelection(List<Dashboard> dashboards) async {
    if (dashboards.isEmpty) {
      if (state != null) {
        state = null;
        await _prefs.clearSelectedTeamId();
      }
      return;
    }

    final ids = dashboards.map((d) => d.teamId).toSet();
    if (state != null && ids.contains(state)) {
      return;
    }

    final pick = dashboards.first.teamId;
    state = pick;
    await _prefs.setSelectedTeamId(pick);
  }

  Future<void> clearIfMatches(int teamId) async {
    if (state == teamId) {
      state = null;
      await _prefs.clearSelectedTeamId();
    }
  }
}
