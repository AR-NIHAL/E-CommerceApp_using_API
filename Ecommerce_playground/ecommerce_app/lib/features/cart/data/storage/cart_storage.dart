import 'package:hive/hive.dart';

import '../../../../core/storage/hive_boxes.dart';
import '../../domain/entities/cart_item.dart';

abstract class CartStorage {
  List<CartItem> readItems();

  void saveItems(List<CartItem> items);

  void clear();
}

class HiveCartStorage implements CartStorage {
  static const String _itemsKey = 'items';

  @override
  List<CartItem> readItems() {
    final stored = Hive.box(HiveBoxes.cart).get(_itemsKey);
    if (stored == null) return const [];
    return (stored as List).cast<CartItem>();
  }

  @override
  void saveItems(List<CartItem> items) {
    Hive.box(HiveBoxes.cart).put(_itemsKey, items);
  }

  @override
  void clear() {
    Hive.box(HiveBoxes.cart).delete(_itemsKey);
  }
}
