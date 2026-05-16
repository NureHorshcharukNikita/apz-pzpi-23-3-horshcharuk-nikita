import 'dart:io';
import 'dart:typed_data';
import 'package:elevate_mobile/data/models/user/user_model.dart';

abstract class ProfileApi {
  Future<UserModel> getProfile();

  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
  });

  Future<Uint8List> uploadAvatar(File file);
}