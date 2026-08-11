import '../../../../core/storage/hive_boxes.dart';

class AuthTokenStorage {
  static const String _tokenKey = 'accessToken';
  static const String _userJsonKey = 'userJson';

  Future<void> save({required String token, required String userJson}) async {
    final box = await HiveBoxes.openAuthBox();
    await box.put(_tokenKey, token);
    await box.put(_userJsonKey, userJson);
  }

  Future<String?> readToken() async {
    final box = await HiveBoxes.openAuthBox();
    return box.get(_tokenKey) as String?;
  }

  Future<String?> readUserJson() async {
    final box = await HiveBoxes.openAuthBox();
    return box.get(_userJsonKey) as String?;
  }

  Future<void> clear() async {
    final box = await HiveBoxes.openAuthBox();
    await box.delete(_tokenKey);
    await box.delete(_userJsonKey);
  }
}
