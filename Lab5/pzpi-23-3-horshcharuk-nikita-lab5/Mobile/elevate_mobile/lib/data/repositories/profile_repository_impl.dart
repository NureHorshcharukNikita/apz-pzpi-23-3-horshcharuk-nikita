import 'dart:io';
import 'dart:typed_data';
import 'package:elevate_mobile/data/datasources/remote/profile/profile_api.dart';
import 'package:elevate_mobile/domain/entities/user/user.dart';
import 'package:elevate_mobile/domain/repositories/profile/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApi api;

  ProfileRepositoryImpl(this.api);

  @override
  Future<User> getProfile() async {
    final user = await api.getProfile();
    return user.toEntity();
  }

  @override
  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final user = await api.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
    );

    return user.toEntity();
  }

  @override
  Future<Uint8List> uploadAvatar(File file) {
    return api.uploadAvatar(file);
  }
}