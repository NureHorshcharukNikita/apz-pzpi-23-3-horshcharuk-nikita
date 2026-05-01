import 'package:dio/dio.dart';

Dio createDio() {
  return Dio(
    BaseOptions(
      baseUrl: "http://192.168.0.77/api",
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );
}