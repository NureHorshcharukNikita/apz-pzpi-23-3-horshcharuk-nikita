import 'dart:io';

import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:elevate_mobile/domain/usecases/profile/get_profile_usecase.dart';
import 'package:elevate_mobile/domain/usecases/profile/update_profile_usecase.dart';
import 'package:elevate_mobile/domain/usecases/profile/upload_avatar_usecase.dart';
import 'package:elevate_mobile/presentation/states/profile/profile_state.dart';
import 'package:elevate_mobile/providers/profile/profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileViewModelProvider =
StateNotifierProvider<ProfileViewModel, ProfileState>(
      (ref) => ProfileViewModel(
    ref.read(getProfileUseCaseProvider),
    ref.read(updateProfileUseCaseProvider),
    ref.read(uploadAvatarUseCaseProvider),
  ),
);

class ProfileViewModel extends StateNotifier<ProfileState> {

  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UploadAvatarUseCase uploadAvatarUseCase;

  ProfileViewModel(
      this.getProfileUseCase,
      this.updateProfileUseCase,
      this.uploadAvatarUseCase,
      ) : super(const ProfileState.initial()) {
    load();
  }

  Future<void> load() async {
    try {
      state = const ProfileState.loading();

      final user = await getProfileUseCase();

      state = ProfileState.loaded(user);

    } catch (e) {
      state = ProfileState.error(mapError(e));
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final user = await updateProfileUseCase(
      firstName: firstName,
      lastName: lastName,
      email: email,
    );
    state = ProfileState.loaded(user);
  }

  Future<void> uploadAvatar(File file) async {
    final bytes = await uploadAvatarUseCase(file);

    final currentUser = state.maybeWhen(
      loaded: (user) => user,
      orElse: () => null,
    );

    if (currentUser == null) return;

    state = ProfileState.loaded(
      currentUser.copyWith(
        avatarBytes: bytes,
        avatarUrl: "/api/users/avatar",
      ),
    );
  }

  Future<void> logoutUser() async {
    state = const ProfileState.initial();
  }
}