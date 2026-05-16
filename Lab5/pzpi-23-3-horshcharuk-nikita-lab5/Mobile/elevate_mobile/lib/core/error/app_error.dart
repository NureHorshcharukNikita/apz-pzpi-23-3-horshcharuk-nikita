import 'package:dio/dio.dart';

String errorMessageForUi(Object? error) {
  if (error == null) {
    return 'Something went wrong.';
  }
  if (error is String) {
    return error;
  }
  return mapError(error);
}

String mapError(Object e) {
  if (e is DioException) {
    final code = e.response?.statusCode;
    final data = e.response?.data;

    if (data is Map) {
      final message =
          data['message'] ?? data['title'] ?? data['error'];

      if (message != null) {
        if (message == 'Unauthorized') {
          return 'Invalid login or password';
        }

        return message.toString();
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The server is taking too long to respond. '
            'Check your connection and try again.';

      case DioExceptionType.connectionError:
        return 'Could not reach the server. '
            'Check your internet connection and try again.';

      case DioExceptionType.badCertificate:
        return 'Secure connection could not be verified.';

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        break;
    }

    if (code == 404) {
      return 'Not found. If this is Join team, deploy the latest API or check the team id.';
    }

    if (code == null) {
      final err = e.error;
      if (err != null) {
        final low = err.toString().toLowerCase();
        if (low.contains('socket') ||
            low.contains('host lookup') ||
            low.contains('network') ||
            low.contains('connection refused') ||
            low.contains('failed host')) {
          return 'Could not reach the server. '
              'Check your internet connection and try again.';
        }
      }
      return 'Could not reach the server. '
          'Check your connection and try again.';
    }

    if (code >= 500) {
      return 'The server had a problem ($code). Please try again later.';
    }

    return 'Something went wrong (HTTP $code).';
  }

  return e.toString().replaceAll('Exception: ', '');
}
