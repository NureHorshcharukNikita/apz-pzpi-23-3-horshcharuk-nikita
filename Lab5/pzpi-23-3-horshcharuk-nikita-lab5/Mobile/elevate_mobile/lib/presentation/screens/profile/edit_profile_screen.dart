import 'dart:io';

import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:elevate_mobile/presentation/widgets/profile/edit_profile_avatar_section.dart';
import 'package:elevate_mobile/presentation/widgets/profile/edit_profile_name_email_fields.dart';
import 'package:elevate_mobile/presentation/viewmodels/profile/profile_viewmodel.dart';
import 'package:elevate_mobile/presentation/widgets/load_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();

  bool initialized = false;
  bool saving = false;

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    super.dispose();
  }

  Future<void> pickAvatar() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    try {
      await ref
          .read(profileViewModelProvider.notifier)
          .uploadAvatar(File(image.path));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapError(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
      ),
      body: state.when(
        initial: () => const Center(
          child: CircularProgressIndicator(),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e) => Center(
          child: LoadErrorView(
            message: e,
            onRetry: () =>
                ref.read(profileViewModelProvider.notifier).load(),
          ),
        ),
        loaded: (user) {
          if (!initialized) {
            firstName.text = user.firstName;
            lastName.text = user.lastName;
            email.text = user.email;
            initialized = true;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              EditProfileAvatarSection(
                avatarBytes: user.avatarBytes,
                onChangeAvatar: pickAvatar,
              ),
              const SizedBox(height: 16),
              EditProfileNameEmailFields(
                firstName: firstName,
                lastName: lastName,
                email: email,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        final fn = firstName.text.trim();
                        final ln = lastName.text.trim();
                        final em = email.text.trim();
                        if (fn.isEmpty || ln.isEmpty || em.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please fill in first name, last name and email.',
                              ),
                            ),
                          );
                          return;
                        }
                        setState(() => saving = true);
                        try {
                          await ref
                              .read(profileViewModelProvider.notifier)
                              .updateProfile(
                                firstName: fn,
                                lastName: ln,
                                email: em,
                              );
                          if (context.mounted) {
                            context.pop();
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(mapError(e))),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => saving = false);
                          }
                        }
                      },
                child: saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save profile'),
              ),
            ],
          );
        },
      ),
    );
  }
}
