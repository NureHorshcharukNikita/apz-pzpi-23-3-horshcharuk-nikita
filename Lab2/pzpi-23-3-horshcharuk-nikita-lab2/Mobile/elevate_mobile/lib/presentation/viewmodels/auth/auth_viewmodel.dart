import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:elevate_mobile/domain/usecases/auth/logout_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elevate_mobile/providers/auth/auth_provider.dart';
import 'package:elevate_mobile/domain/usecases/auth/login_usecase.dart';
import 'package:elevate_mobile/domain/usecases/auth/register_usecase.dart';
import 'package:elevate_mobile/presentation/states/auth/auth_state.dart';

final authViewModelProvider =
StateNotifierProvider<AuthViewModel, AuthState>(
      (ref) => AuthViewModel(
    ref.read(loginUseCaseProvider),
    ref.read(registerUseCaseProvider),
    ref.read(logoutUseCaseProvider),
  ),
);

class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;

  AuthViewModel(
      this.loginUseCase,
      this.registerUseCase,
      this.logoutUseCase,
      ) : super(const AuthState.initial());

  Future<void> login({
    required String loginOrEmail,
    required String password,
  }) async {
    try {
      state = const AuthState.loading();

      await loginUseCase(
        loginOrEmail: loginOrEmail.trim(),
        password: password.trim(),
      );

      state = AuthState.authenticated();

    } catch (e) {
      state = AuthState.error(mapError(e));
    }
  }

  Future<void> register({
    required String login,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      state = const AuthState.loading();

      await registerUseCase(
        login: login.trim(),
        email: email.trim(),
        password: password.trim(),
        firstName: firstName.trim(),
        lastName: lastName.trim(),
      );

      state = AuthState.authenticated();

    } catch (e) {
      state = AuthState.error(mapError(e));
    }
  }

  Future<void> logout() async {
    await logoutUseCase();
    state = const AuthState.initial();
  }
}