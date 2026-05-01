import 'package:dio/dio.dart';
import 'package:elevate_mobile/data/datasources/remote/auth/auth_api.dart';
import 'package:elevate_mobile/data/models/auth/response/auth_response.dart';

class AuthApiImpl implements AuthApi {
  final Dio dio;

  AuthApiImpl(this.dio);

  @override
  Future<AuthResponse> login({
    required String loginOrEmail,
    required String password,
  }) async {
    final response = await dio.post(
      '/auth/login',
      data: {
        'loginOrEmail': loginOrEmail,
        'password': password,
      },
    );

    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<AuthResponse> register({
    required String login,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await dio.post(
      '/auth/register',
      data: {
        'login': login,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      },
    );

    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}