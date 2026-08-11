import 'package:hive/hive.dart';

class HiveBoxes {
  const HiveBoxes._();

  static const String auth = 'auth_box';
  static const String cart = 'cart_box';
  static const String wishlist = 'wishlist_box';

  static Future<Box> openAuthBox() async {
    if (Hive.isBoxOpen(auth)) return Hive.box(auth);
    return Hive.openBox(auth);
  }
}
