abstract class AuthRepository {
  Future<void> register({
    required String login,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<void> login({
    required String loginOrEmail,
    required String password,
  });

  Future<String?> getToken();

  Future<void> clearToken();

  Future<void> logout();
}