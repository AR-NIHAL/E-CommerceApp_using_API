import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/auth/data/datasources/auth_remote_source.dart';
import 'package:ecommerce_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ecommerce_app/features/auth/data/storage/auth_token_storage.dart';
import 'package:ecommerce_app/features/auth/domain/entities/auth_user.dart';

class _FakeRemoteSource implements AuthRemoteDataSource {
  _FakeRemoteSource({this.shouldThrow = false});

  final bool shouldThrow;
  final calls = <String>[];

  @override
  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    calls.add('$username:$password');
    if (shouldThrow) throw const AuthFailure();
    return const AuthUser(
      id: 1,
      username: 'emilys',
      email: 'e@test.com',
      firstName: 'Emily',
      lastName: 'Johnson',
      gender: 'female',
      image: '',
      accessToken: 'token-abc',
    );
  }
}

class _FakeTokenStorage implements AuthTokenStorage {
  String? token;
  String? userJson;
  bool cleared = false;

  @override
  Future<void> save({required String token, required String userJson}) async {
    this.token = token;
    this.userJson = userJson;
  }

  @override
  Future<String?> readToken() async => token;

  @override
  Future<String?> readUserJson() async => userJson;

  @override
  Future<void> clear() async {
    cleared = true;
    token = null;
    userJson = null;
  }
}

void main() {
  late _FakeRemoteSource remote;
  late _FakeTokenStorage storage;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = _FakeRemoteSource();
    storage = _FakeTokenStorage();
    repository = AuthRepositoryImpl(
      remoteSource: remote,
      tokenStorage: storage,
    );
  });

  test('login persists user and returns it', () async {
    final user = await repository.login(
      username: 'emilys',
      password: 'emilyspass',
    );

    expect(user.accessToken, 'token-abc');
    expect(remote.calls, ['emilys:emilyspass']);
    expect(storage.token, 'token-abc');
    expect(storage.userJson, isNotNull);
  });

  test('login failure propagates failure', () async {
    remote = _FakeRemoteSource(shouldThrow: true);
    repository = AuthRepositoryImpl(
      remoteSource: remote,
      tokenStorage: storage,
    );

    expect(
      () => repository.login(username: 'x', password: 'y'),
      throwsA(isA<Failure>()),
    );
  });

  test('restoreSession returns null when nothing stored', () async {
    expect(await repository.restoreSession(), isNull);
  });

  test('restoreSession hydrates a persisted user', () async {
    await repository.login(username: 'emilys', password: 'emilyspass');
    final restored = await repository.restoreSession();

    expect(restored, isNotNull);
    expect(restored!.username, 'emilys');
  });

  test('logout clears stored session', () async {
    await repository.login(username: 'emilys', password: 'emilyspass');
    await repository.logout();

    expect(storage.cleared, isTrue);
    expect(await repository.restoreSession(), isNull);
  });
}
