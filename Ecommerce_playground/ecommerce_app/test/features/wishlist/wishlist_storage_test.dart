import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:ecommerce_app/core/storage/adapters/product_adapter.dart';
import 'package:ecommerce_app/core/storage/hive_boxes.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/wishlist/data/storage/wishlist_storage.dart';

Product _product(int id) {
  return Product.fromJson({
    'id': id,
    'title': 'Product $id',
    'description': 'Description for $id',
    'category': 'beauty',
    'price': 100.0,
    'discountPercentage': 25.0,
    'rating': 4.5,
    'stock': 10,
    'brand': 'Acme',
    'thumbnail': 'https://example.com/$id/thumb.jpg',
    'images': ['https://example.com/$id/1.jpg', 'https://example.com/$id/2.jpg'],
  });
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('wishlist_storage_test');
    Hive.init(tempDir.path);
    Hive.registerAdapter(ProductAdapter());
    await Hive.openBox(HiveBoxes.wishlist);
  });

  tearDownAll(() async {
    await Hive.close();
  });

  setUp(() {
    Hive.box(HiveBoxes.wishlist).clear();
  });

  test('readProducts returns empty when nothing stored', () {
    final storage = HiveWishlistStorage();

    expect(storage.readProducts(), isEmpty);
  });

  test('saveProducts round-trips through readProducts', () {
    final storage = HiveWishlistStorage();
    storage.saveProducts([_product(1), _product(2)]);

    final restored = storage.readProducts();

    expect(restored, hasLength(2));
    expect(restored[0].id, 1);
    expect(restored[0].title, 'Product 1');
    expect(restored[0].images, hasLength(2));
    expect(restored[0].hasDiscount, isTrue);
    expect(restored[1].id, 2);
  });

  test('clear removes stored products', () {
    final storage = HiveWishlistStorage();
    storage.saveProducts([_product(1)]);

    storage.clear();

    expect(storage.readProducts(), isEmpty);
  });
}
