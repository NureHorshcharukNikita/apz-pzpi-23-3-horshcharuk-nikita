import 'package:elevate_mobile/core/router/app_router.dart';
import 'package:elevate_mobile/presentation/viewmodels/auth/auth_viewmodel.dart';
import 'package:elevate_mobile/presentation/states/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final loginOrEmailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    loginOrEmailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (!context.mounted) return;
      final route = ModalRoute.of(context);
      if (route == null || !route.isCurrent) return;

      next.whenOrNull(
        authenticated: () {
          context.go(AppRoutes.mainHome);
        },
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
      );
    });

    final isLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (isLoading) const LinearProgressIndicator(),

            const SizedBox(height: 16),

            TextField(
              controller: loginOrEmailController,
              decoration: const InputDecoration(
                labelText: 'Login or Email',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                  ref.read(authViewModelProvider.notifier).login(
                    loginOrEmail:
                    loginOrEmailController.text.trim(),
                    password:
                    passwordController.text.trim(),
                  );
                },
                child: const Text('Login'),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      await context.push(AppRoutes.register);
                      if (!context.mounted) return;
                      loginOrEmailController.clear();
                      passwordController.clear();
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}