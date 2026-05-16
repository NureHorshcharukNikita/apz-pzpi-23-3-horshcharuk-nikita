import 'package:elevate_mobile/domain/entities/user/user.dart';
import 'package:elevate_mobile/domain/repositories/profile/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<User> call({
    required String firstName,
    required String lastName,
    required String email,
  }) {
    return repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
    );
  }
}