import 'package:hive/hive.dart';

class HiveBoxes {
  const HiveBoxes._();

  static const String auth = 'auth_box';
  static const String cart = 'cart_box';
  static const String wishlist = 'wishlist_box';
  static const String settings = 'settings_box';
  static const String orders = 'orders_box';

  static Future<Box> openAuthBox() async {
    if (Hive.isBoxOpen(auth)) return Hive.box(auth);
    return Hive.openBox(auth);
  }

  static Future<Box> openCartBox() async {
    if (Hive.isBoxOpen(cart)) return Hive.box(cart);
    return Hive.openBox(cart);
  }

  static Future<Box> openWishlistBox() async {
    if (Hive.isBoxOpen(wishlist)) return Hive.box(wishlist);
    return Hive.openBox(wishlist);
  }

  static Future<Box> openSettingsBox() async {
    if (Hive.isBoxOpen(settings)) return Hive.box(settings);
    return Hive.openBox(settings);
  }

  static Future<Box> openOrdersBox() async {
    if (Hive.isBoxOpen(orders)) return Hive.box(orders);
    return Hive.openBox(orders);
  }
}
