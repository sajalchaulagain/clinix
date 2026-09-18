import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../errors/app_exception.dart';

/// Converts low-level networking errors into user-safe [AppException]s.
///
/// Every repository that talks to the backend should route Dio errors through
/// [ApiErrorMapper.map] so the rest of the app deals with one error vocabulary.
class ApiErrorMapper {
  ApiErrorMapper._();

  static AppException map(Object error) {
    if (error is AppException) return error;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TimeoutAppException(cause: error);
        case DioExceptionType.connectionError:
          return NoNetworkException(cause: error);
        case DioExceptionType.badResponse:
          return _fromStatusCode(error);
        case DioExceptionType.cancel:
          return UnknownAppException(cause: error);
        case DioExceptionType.badCertificate:
        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return NoNetworkException(cause: error);
          }
          return UnknownAppException(cause: error);
        default:
          return UnknownAppException(cause: error);
      }
    }

    if (error is SocketException) return NoNetworkException(cause: error);
    if (error is TimeoutException) return TimeoutAppException(cause: error);

    return UnknownAppException(cause: error);
  }

  static AppException _fromStatusCode(DioException error) {
    final code = error.response?.statusCode ?? 0;
    // The future FastAPI error contract: {"detail": "..."} (FastAPI default).
    // We surface the server's human-readable detail when present, but only
    // the backend should decide what is safe to show.
    final serverMessage = _extractServerMessage(error.response?.data);

    switch (code) {
      case 400:
      case 422:
        return ValidationException(
          serverMessage ?? 'Please check the information you entered.',
        );
      case 401:
        return UnauthorizedException(cause: error);
      case 403:
        return PermissionDeniedException(cause: error);
      case 404:
        return NotFoundException(serverMessage ?? 'The requested item was not found.');
      default:
        return ServerException(cause: error, statusCode: code);
    }
  }

  static String? _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail'] ?? data['message'];
      if (detail is String && detail.isNotEmpty) return detail;
    }
    return null;
  }
}
