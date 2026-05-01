import 'dart:io';
import 'dart:typed_data';
import 'package:elevate_mobile/domain/repositories/profile/profile_repository.dart';

class UploadAvatarUseCase {
  final ProfileRepository repository;

  UploadAvatarUseCase(this.repository);

  Future<Uint8List> call(File file) {
    return repository.uploadAvatar(file);
  }
}