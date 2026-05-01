import 'package:elevate_mobile/data/datasources/local/auth_preferences.dart';
import 'package:elevate_mobile/data/datasources/remote/auth/auth_api.dart';
import 'package:elevate_mobile/domain/repositories/auth/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi api;
  final AuthPreferences authPreferences;

  AuthRepositoryImpl(this.api, this.authPreferences);

  @override
  Future<void> login({
    required String loginOrEmail,
    required String password,
  }) async {
    final result = await api.login(
      loginOrEmail: loginOrEmail,
      password: password,
    );

    await authPreferences.setToken(result.token);
    await authPreferences.setUserId(result.user.id);
  }

  @override
  Future<String?> getToken() async {
    return authPreferences.getToken();
  }

  @override
  Future<void> clearToken() async {
    await authPreferences.clearToken();
  }

  @override
  Future<void> logout() async {
    try {
      await api.logout();
    } catch (_) {}

    await authPreferences.clearToken();
  }

  @override
  Future<void> register({
    required String login,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final result = await api.register(
      login: login,
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );

    await authPreferences.setToken(result.token);
    await authPreferences.setUserId(result.user.id);
  }
}