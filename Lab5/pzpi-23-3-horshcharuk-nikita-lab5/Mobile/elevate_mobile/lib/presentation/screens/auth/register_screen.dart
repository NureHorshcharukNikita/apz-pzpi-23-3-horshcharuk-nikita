import 'package:elevate_mobile/core/router/app_router.dart';
import 'package:elevate_mobile/presentation/viewmodels/auth/auth_viewmodel.dart';
import 'package:elevate_mobile/presentation/states/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final login = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();

  @override
  void dispose() {
    login.dispose();
    email.dispose();
    password.dispose();
    firstName.dispose();
    lastName.dispose();
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
        error: (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e)),
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
        automaticallyImplyLeading: false,
        title: const Text("Register"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isLoading) const LinearProgressIndicator(),

          const SizedBox(height: 16),

          TextField(
            controller: login,
            decoration: const InputDecoration(
              labelText: "Login",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: email,
            decoration: const InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: firstName,
            decoration: const InputDecoration(
              labelText: "First name",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: lastName,
            decoration: const InputDecoration(
              labelText: "Last name",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: password,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Password",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
              ref.read(authViewModelProvider.notifier).register(
                login: login.text.trim(),
                email: email.text.trim(),
                password: password.text.trim(),
                firstName: firstName.text.trim(),
                lastName: lastName.text.trim(),
              );
            },
            child: const Text("Register"),
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: isLoading
                ? null
                : () {
              context.pop();
            },
            child: const Text("Already have an account? Login"),
          ),
        ],
      ),
    );
  }
}