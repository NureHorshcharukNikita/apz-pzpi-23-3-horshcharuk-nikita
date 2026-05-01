import 'package:elevate_mobile/core/router/app_router.dart';
import 'package:flutter/material.dart';

class ElevateApp extends StatelessWidget {
  const ElevateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Elevate',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
    );
  }
}