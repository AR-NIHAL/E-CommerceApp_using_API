import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:ecommerce_app/core/storage/adapters/cart_item_adapter.dart';
import 'package:ecommerce_app/core/storage/adapters/order_adapter.dart';
import 'package:ecommerce_app/core/storage/adapters/product_adapter.dart';
import 'package:ecommerce_app/core/storage/hive_boxes.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/checkout/data/storage/order_storage.dart';
import 'package:ecommerce_app/features/checkout/domain/entities/order.dart';
import 'package:ecommerce_app/features/checkout/domain/entities/payment_method.dart';
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

Order _order() {
  final items = [
    CartItem(product: _product(1), quantity: 2),
    CartItem(product: _product(2), quantity: 1),
  ];
  final subtotal = Order.subtotalFor(items);
  return Order(
    id: 'ORD-123456',
    placedAt: DateTime(2026, 1, 15, 10, 30),
    items: items,
    fullName: 'Jane Doe',
    phone: '1234567890',
    address: '1 Main St',
    city: 'Springfield',
    state: 'IL',
    zip: '62701',
    paymentMethod: PaymentMethod.card,
    subtotal: subtotal,
    shipping: Order.shippingFor(subtotal),
    total: subtotal + Order.shippingFor(subtotal),
  );
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('order_storage_test');
    Hive.init(tempDir.path);
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(CartItemAdapter());
    Hive.registerAdapter(OrderAdapter());
    await Hive.openBox(HiveBoxes.orders);
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() {
    Hive.box(HiveBoxes.orders).clear();
  });

  test('readOrders returns empty when nothing stored', () {
    final storage = HiveOrderStorage();

    expect(storage.readOrders(), isEmpty);
  });

  test('saveOrders round-trips through readOrders', () {
    final storage = HiveOrderStorage();
    storage.saveOrders([_order()]);

    final restored = storage.readOrders();

    expect(restored, hasLength(1));
    final order = restored.single;
    expect(order.id, 'ORD-123456');
    expect(order.placedAt, DateTime(2026, 1, 15, 10, 30));
    expect(order.items, hasLength(2));
    expect(order.items.first.product.id, 1);
    expect(order.items.first.quantity, 2);
    expect(order.fullName, 'Jane Doe');
    expect(order.paymentMethod, PaymentMethod.card);
    expect(order.subtotal, 225.0);
  });

  test('clear removes stored orders', () {
    final storage = HiveOrderStorage();
    storage.saveOrders([_order()]);

    storage.clear();

    expect(storage.readOrders(), isEmpty);
  });
}