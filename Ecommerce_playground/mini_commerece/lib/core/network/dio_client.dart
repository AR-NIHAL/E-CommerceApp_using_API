import 'package:dio/dio.dart';
import 'api_endpoints.dart';

class DioClient {
  DioClient._();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Optional: simple log (beginner-friendly)
  static void addInterceptors() {
    dio.interceptors.add(
      LogInterceptor(requestBody: false, responseBody: false),
    );
  }
}
