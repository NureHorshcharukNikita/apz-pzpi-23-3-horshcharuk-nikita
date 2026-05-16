import 'package:elevate_mobile/domain/repositories/auth/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<void> call({
    required String login,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    if (login.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty) {
      throw Exception("Fill all fields");
    }

    if (password.length < 4) {
      throw Exception("Password too short");
    }

    await repository.register(
      login: login,
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
  }
}