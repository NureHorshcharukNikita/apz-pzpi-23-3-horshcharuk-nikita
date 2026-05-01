import 'package:elevate_mobile/data/models/auth/response/auth_response.dart';

abstract class AuthApi {
  Future<AuthResponse> login({
    required String loginOrEmail,
    required String password,
  });

  Future<AuthResponse> register({
    required String login,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<void> logout();
}
