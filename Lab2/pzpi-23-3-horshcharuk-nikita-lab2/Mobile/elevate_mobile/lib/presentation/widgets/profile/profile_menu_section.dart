import 'package:elevate_mobile/core/router/app_router.dart';
import 'package:elevate_mobile/presentation/viewmodels/profile/profile_viewmodel.dart';
import 'package:elevate_mobile/providers/auth/auth_provider.dart';
import 'package:elevate_mobile/providers/team/selected_team_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileMenuSection extends ConsumerWidget {
  const ProfileMenuSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.groups),
            title: const Text('My Teams'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go(AppRoutes.mainTeams);
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text('Achievements'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push(AppRoutes.achievements);
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Activity'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push(AppRoutes.activity);
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await context.push(AppRoutes.editProfile);

              if (context.mounted) {
                ref.read(profileViewModelProvider.notifier).load();
              }
            },
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await ref.read(logoutUseCaseProvider).call();
              ref.invalidate(selectedTeamIdProvider);
              await ref.read(profileViewModelProvider.notifier).logoutUser();

              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ),
      ],
    );
  }
}
