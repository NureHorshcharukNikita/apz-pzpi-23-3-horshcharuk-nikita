import 'dart:io';
import 'dart:typed_data';

import 'package:elevate_mobile/data/datasources/remote/profile/profile_api.dart';
import 'package:elevate_mobile/data/models/user/user_model.dart';

class ProfileApiFake implements ProfileApi {
  @override
  Future<UserModel> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return UserModel(
      userID: 1,
      login: "admin",
      email: "admin@test.com",
      firstName: "Nikita",
      lastName: "Horshcharuk",
      role: "Employee",
      isActive: true,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  @override
  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return UserModel(
      userID: 1,
      login: "admin",
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: "Employee",
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLoginAt: DateTime.now(),
    );
  }

  @override
  Future<Uint8List> uploadAvatar(File file) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return file.readAsBytes();
  }
}