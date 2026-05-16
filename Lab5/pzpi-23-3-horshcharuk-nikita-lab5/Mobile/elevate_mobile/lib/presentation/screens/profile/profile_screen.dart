import 'package:elevate_mobile/presentation/widgets/profile/profile_header_section.dart';
import 'package:elevate_mobile/presentation/widgets/profile/profile_menu_section.dart';
import 'package:elevate_mobile/presentation/viewmodels/profile/profile_viewmodel.dart';
import 'package:elevate_mobile/presentation/widgets/load_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileViewModelProvider);

    return state.when(
      initial: () => const Center(
        child: CircularProgressIndicator(),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (e) => Center(
        child: LoadErrorView(
          message: e,
          onRetry: () => ref.read(profileViewModelProvider.notifier).load(),
        ),
      ),
      loaded: (user) {
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(profileViewModelProvider.notifier).load(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              ProfileHeaderSection(user: user),
              const SizedBox(height: 16),
              const ProfileMenuSection(),
            ],
          ),
        );
      },
    );
  }
}
