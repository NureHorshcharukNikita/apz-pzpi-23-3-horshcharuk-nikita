import 'dart:io';
import 'dart:typed_data';
import 'package:elevate_mobile/domain/entities/user/user.dart';

abstract class ProfileRepository {
  Future<User> getProfile();

  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
  });

  Future<Uint8List> uploadAvatar(File file);
}