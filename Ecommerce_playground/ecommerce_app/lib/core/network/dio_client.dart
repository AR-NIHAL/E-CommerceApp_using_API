import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_constants.dart';
import 'dio_interceptors.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
    ),
  )..interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
    ]);
});
