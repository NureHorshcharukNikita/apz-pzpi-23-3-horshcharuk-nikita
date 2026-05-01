import 'package:shared_preferences/shared_preferences.dart';

class AuthPreferences {
  AuthPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';
  static const _selectedTeamIdKey = 'selected_team_id';

  Future<void> setToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> setUserId(int userId) async {
    await _prefs.setInt(_userIdKey, userId);
  }

  int? getUserId() {
    return _prefs.getInt(_userIdKey);
  }

  Future<void> setSelectedTeamId(int teamId) async {
    await _prefs.setInt(_selectedTeamIdKey, teamId);
  }

  int? getSelectedTeamId() {
    return _prefs.getInt(_selectedTeamIdKey);
  }

  Future<void> clearSelectedTeamId() async {
    await _prefs.remove(_selectedTeamIdKey);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_selectedTeamIdKey);
  }
}