import 'package:elevate_mobile/domain/repositories/auth/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<void> call({
    required String loginOrEmail,
    required String password,
  }) async {
    if (loginOrEmail.isEmpty || password.isEmpty) {
      throw Exception("Fill in all fields");
    }

    if (password.length < 4) {
      throw Exception("Password too short");
    }

    await repository.login(
      loginOrEmail: loginOrEmail,
      password: password,
    );
  }
}