import 'package:dio/dio.dart';
import 'package:elevate_mobile/core/network/api_client.dart';
import 'package:elevate_mobile/providers/auth/auth_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = createDio();

  dio.interceptors.clear();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final authPrefs = ref.read(authPreferencesProvider);
        final token = authPrefs.getToken();

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        handler.next(options);
      },

      onError: (e, handler) {
        String message = "Unknown error";

        if (e.response?.data != null) {
          final data = e.response!.data;

          if (data is Map && data["message"] != null) {
            message = data["message"];
          } else {
            message = data.toString();
          }
        } else if (e.message != null) {
          message = e.message!;
        }

        handler.reject(
          DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            type: e.type,
            error: message,
          ),
        );
      },
    ),
  );

  return dio;
});