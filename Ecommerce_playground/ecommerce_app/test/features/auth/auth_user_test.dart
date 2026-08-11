import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app/features/auth/domain/entities/auth_user.dart';

void main() {
  const json = {
    'id': 1,
    'username': 'emilys',
    'email': 'emily.johnson@x.dummyjson.com',
    'firstName': 'Emily',
    'lastName': 'Johnson',
    'gender': 'female',
    'image': 'https://dummyjson.com/icon/emilys/128',
    'accessToken': 'token-abc',
  };

  test('AuthUser.fromJson maps all fields', () {
    final user = AuthUser.fromJson(json);

    expect(user.id, 1);
    expect(user.username, 'emilys');
    expect(user.email, 'emily.johnson@x.dummyjson.com');
    expect(user.firstName, 'Emily');
    expect(user.lastName, 'Johnson');
    expect(user.gender, 'female');
    expect(user.image, 'https://dummyjson.com/icon/emilys/128');
    expect(user.accessToken, 'token-abc');
    expect(user.fullName, 'Emily Johnson');
  });

  test('AuthUser.fromJson tolerates missing optional fields', () {
    final user = AuthUser.fromJson({
      'id': 2,
      'username': 'michaelw',
      'email': 'michael.williams@x.dummyjson.com',
      'firstName': 'Michael',
      'lastName': 'Williams',
      'accessToken': 'token-def',
    });

    expect(user.gender, '');
    expect(user.image, '');
  });

  test('AuthUser.toJson round-trips through fromJson', () {
    final user = AuthUser.fromJson(json);
    final restored = AuthUser.fromJson(user.toJson());

    expect(restored.toJson(), user.toJson());
  });
}
