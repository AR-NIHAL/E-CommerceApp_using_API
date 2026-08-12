import 'package:hive/hive.dart';

import '../../../../core/storage/hive_boxes.dart';
import '../../../products/domain/entities/product.dart';

abstract class WishlistStorage {
  List<Product> readProducts();

  void saveProducts(List<Product> products);

  void clear();
}

class HiveWishlistStorage implements WishlistStorage {
  static const String _itemsKey = 'items';

  @override
  List<Product> readProducts() {
    final stored = Hive.box(HiveBoxes.wishlist).get(_itemsKey);
    if (stored == null) return const [];
    return (stored as List).cast<Product>();
  }

  @override
  void saveProducts(List<Product> products) {
    Hive.box(HiveBoxes.wishlist).put(_itemsKey, products);
  }

  @override
  void clear() {
    Hive.box(HiveBoxes.wishlist).delete(_itemsKey);
  }
}
