import 'package:dio/dio.dart';

import '../../../../core/errors/exception_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_constants.dart';
import '../../domain/entities/auth_user.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.authLogin,
        data: {'username': username, 'password': password},
      );
      return AuthUser.fromJson(response.data!);
    } on DioException catch (error) {
      throw FailureMapper.fromDio(error);
    } catch (_) {
      throw const UnknownFailure();
    }
  }
}
