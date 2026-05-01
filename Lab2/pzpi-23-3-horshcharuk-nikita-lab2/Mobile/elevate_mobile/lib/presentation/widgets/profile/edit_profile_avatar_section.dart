import 'package:elevate_mobile/presentation/widgets/profile_avatar_circle.dart';
import 'package:flutter/material.dart';

class EditProfileAvatarSection extends StatelessWidget {
  final List<int>? avatarBytes;
  final VoidCallback onChangeAvatar;

  const EditProfileAvatarSection({
    super.key,
    required this.avatarBytes,
    required this.onChangeAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ProfileAvatarCircle(
            radius: 40,
            bytes: avatarBytes,
          ),
          TextButton(
            onPressed: onChangeAvatar,
            child: const Text('Change avatar'),
          ),
        ],
      ),
    );
  }
}
