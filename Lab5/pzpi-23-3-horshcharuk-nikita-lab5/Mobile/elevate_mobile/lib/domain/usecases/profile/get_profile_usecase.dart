import 'package:elevate_mobile/domain/entities/user/user.dart';
import 'package:elevate_mobile/domain/repositories/profile/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<User> call() {
    return repository.getProfile();
  }
}