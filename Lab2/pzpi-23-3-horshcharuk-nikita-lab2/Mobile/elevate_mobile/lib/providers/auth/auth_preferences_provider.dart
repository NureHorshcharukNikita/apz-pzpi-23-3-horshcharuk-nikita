import 'package:elevate_mobile/data/datasources/local/auth_preferences.dart';
import 'package:elevate_mobile/providers/core/preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authPreferencesProvider = Provider<AuthPreferences>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return AuthPreferences(prefs);
});