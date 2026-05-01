import 'package:elevate_mobile/providers/auth/auth_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authGuardProvider = FutureProvider<bool>((ref) async {
  final prefs = ref.read(authPreferencesProvider);
  final token = await prefs.getToken();
  return token != null;
});