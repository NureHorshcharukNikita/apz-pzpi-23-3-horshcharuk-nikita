import 'package:elevate_mobile/core/router/app_router.dart';
import 'package:elevate_mobile/presentation/widgets/load_error_view.dart';
import 'package:elevate_mobile/providers/auth/auth_guard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authGuardProvider);

    return auth.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Scaffold(
        body: Center(
          child: LoadErrorView.fromError(
            e,
            title: 'Startup problem',
            onRetry: () => ref.invalidate(authGuardProvider),
          ),
        ),
      ),
      data: (isAuth) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isAuth) {
            context.go(AppRoutes.mainHome);
          } else {
            context.go(AppRoutes.login);
          }
        });

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}