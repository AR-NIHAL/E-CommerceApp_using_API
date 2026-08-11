import 'dart:convert';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_source.dart';
import '../storage/auth_token_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteSource,
    required AuthTokenStorage tokenStorage,
  })  : _remoteSource = remoteSource,
        _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _remoteSource;
  final AuthTokenStorage _tokenStorage;

  @override
  Future<AuthUser?> restoreSession() async {
    final userJson = await _tokenStorage.readUserJson();
    if (userJson == null || userJson.isEmpty) return null;

    try {
      return AuthUser.fromJson(
        jsonDecode(userJson) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    final user = await _remoteSource.login(
      username: username,
      password: password,
    );

    final userJson = jsonEncode(user.toJson());
    await _tokenStorage.save(token: user.accessToken, userJson: userJson);
    return user;
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clear();
  }
}
