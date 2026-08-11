import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  Future<AuthUser> login({required String username, required String password});

  Future<AuthUser?> restoreSession();

  Future<void> logout();
}
