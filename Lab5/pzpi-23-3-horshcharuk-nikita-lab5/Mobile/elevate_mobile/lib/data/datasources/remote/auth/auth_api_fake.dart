import 'package:elevate_mobile/data/datasources/remote/auth/auth_api.dart';
import 'package:elevate_mobile/data/models/auth/response/auth_response.dart';
import 'package:elevate_mobile/data/models/auth/user/auth_user_model.dart';

class AuthApiFake implements AuthApi {
  @override
  Future<AuthResponse> login({
    required String loginOrEmail,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if ((loginOrEmail == 'admin' || loginOrEmail == 'admin@test.com') &&
        password == '1234') {
      return AuthResponse(
        token: 'fake_token_123',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        user: const AuthUserModel(
          id: 1,
          login: 'admin',
          firstName: 'Nikita',
          lastName: 'Horshcharuk',
          role: 'Employee',
        ),
      );
    }

    throw Exception('Invalid login or password');
  }

  @override
  Future<AuthResponse> register({
    required String login,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return AuthResponse(
      token: "fake_register_token",
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      user: AuthUserModel(
        id: 2,
        login: login,
        firstName: firstName,
        lastName: lastName,
        role: "Employee",
      ),
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}