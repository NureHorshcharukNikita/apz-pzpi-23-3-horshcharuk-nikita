import 'package:elevate_mobile/domain/entities/user/user.dart';
import 'package:elevate_mobile/presentation/widgets/profile_avatar_circle.dart';
import 'package:flutter/material.dart';

class ProfileHeaderSection extends StatelessWidget {
  final User user;

  const ProfileHeaderSection({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: ProfileAvatarCircle(
            radius: 40,
            bytes: user.avatarBytes,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${user.firstName} ${user.lastName}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          user.login,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
