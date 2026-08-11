import 'package:dio/dio.dart';

import 'failures.dart';

abstract final class FailureMapper {
  static Failure fromDio(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }

    final statusCode = error.response?.statusCode;
    if (statusCode != null) {
      if (statusCode >= 400 && statusCode < 500) {
        return const AuthFailure();
      }
      return const ServerFailure();
    }

    return const UnknownFailure();
  }

  static Failure fromObject(Object error) {
    return const UnknownFailure();
  }
}
