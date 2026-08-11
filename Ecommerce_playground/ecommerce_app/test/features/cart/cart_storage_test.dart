import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:ecommerce_app/core/storage/adapters/cart_item_adapter.dart';
import 'package:ecommerce_app/core/storage/adapters/product_adapter.dart';
import 'package:ecommerce_app/core/storage/hive_boxes.dart';
import 'package:ecommerce_app/features/cart/data/storage/cart_storage.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

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
    tempDir = await Directory.systemTemp.createTemp('cart_storage_test');
    Hive.init(tempDir.path);
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(CartItemAdapter());
    await Hive.openBox(HiveBoxes.cart);
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() {
    Hive.box(HiveBoxes.cart).clear();
  });

  test('readItems returns empty when nothing stored', () {
    final storage = HiveCartStorage();

    expect(storage.readItems(), isEmpty);
  });

  test('saveItems round-trips through readItems', () {
    final storage = HiveCartStorage();
    storage.saveItems([
      CartItem(product: _product(1), quantity: 2),
      CartItem(product: _product(2), quantity: 1),
    ]);

    final restored = storage.readItems();

    expect(restored, hasLength(2));
    expect(restored[0].product.id, 1);
    expect(restored[0].quantity, 2);
    expect(restored[0].product.title, 'Product 1');
    expect(restored[0].product.images, hasLength(2));
    expect(restored[0].product.hasDiscount, isTrue);
    expect(restored[1].product.id, 2);
    expect(restored[1].quantity, 1);
  });

  test('overwriting saveItems replaces previous data', () {
    final storage = HiveCartStorage();
    storage.saveItems([CartItem(product: _product(1), quantity: 1)]);

    storage.saveItems([CartItem(product: _product(9), quantity: 3)]);

    final restored = storage.readItems();
    expect(restored, hasLength(1));
    expect(restored.single.product.id, 9);
    expect(restored.single.quantity, 3);
  });

  test('clear removes stored items', () {
    final storage = HiveCartStorage();
    storage.saveItems([CartItem(product: _product(1), quantity: 1)]);

    storage.clear();

    expect(storage.readItems(), isEmpty);
  });
}
