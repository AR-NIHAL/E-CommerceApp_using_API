import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app/features/cart/data/storage/cart_storage.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/presentation/providers/cart_dependencies.dart';
import 'package:ecommerce_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

class _InMemoryCartStorage implements CartStorage {
  List<CartItem> stored = [];

  @override
  void clear() => stored = [];

  @override
  List<CartItem> readItems() => List.of(stored);

  @override
  void saveItems(List<CartItem> items) => stored = List.of(items);
}

Product _product(int id, {double price = 10.0, double discount = 0}) {
  return Product.fromJson({
    'id': id,
    'title': 'Product $id',
    'price': price,
    'discountPercentage': discount,
    'rating': 4.0,
  });
}

void main() {
  late ProviderContainer container;
  late CartController controller;
  late _InMemoryCartStorage storage;

  setUp(() {
    storage = _InMemoryCartStorage();
    container = ProviderContainer(
      overrides: [
        cartStorageProvider.overrideWithValue(storage),
      ],
    );
    controller = container.read(cartControllerProvider.notifier);
    addTearDown(container.dispose);
  });

  test('starts empty', () {
    expect(controller.state.items, isEmpty);
    expect(controller.state.totalItems, 0);
    expect(controller.state.totalPrice, 0);
  });

  test('addProduct adds a new item', () {
    controller.addProduct(_product(1));

    expect(controller.state.items, hasLength(1));
    expect(controller.state.totalItems, 1);
    expect(controller.state.totalPrice, 10.0);
  });

  test('addProduct merges quantity for an existing item', () {
    controller.addProduct(_product(1));
    controller.addProduct(_product(1));

    expect(controller.state.items, hasLength(1));
    expect(controller.state.totalItems, 2);
    expect(controller.state.totalPrice, 20.0);
  });

  test('addProduct supports a custom quantity', () {
    controller.addProduct(_product(1), quantity: 3);

    expect(controller.state.totalItems, 3);
    expect(controller.state.totalPrice, 30.0);
  });

  test('addProduct applies discounted price', () {
    controller.addProduct(_product(1, price: 100, discount: 50));

    expect(controller.state.totalPrice, 50.0);
  });

  test('increment increases quantity', () {
    controller.addProduct(_product(1));
    controller.increment(1);

    expect(controller.state.totalItems, 2);
  });

  test('decrement removes the item at quantity 1', () {
    controller.addProduct(_product(1));
    controller.decrement(1);

    expect(controller.state.items, isEmpty);
    expect(controller.state.totalItems, 0);
  });

  test('decrement lowers quantity when above 1', () {
    controller.addProduct(_product(1), quantity: 3);
    controller.decrement(1);

    expect(controller.state.items, hasLength(1));
    expect(controller.state.totalItems, 2);
  });

  test('removeItem removes only the given product', () {
    controller.addProduct(_product(1));
    controller.addProduct(_product(2));

    controller.removeItem(1);

    expect(controller.state.items, hasLength(1));
    expect(controller.state.items.single.product.id, 2);
  });

  test('clear empties the cart', () {
    controller.addProduct(_product(1));
    controller.addProduct(_product(2));

    controller.clear();

    expect(controller.state.items, isEmpty);
    expect(controller.state.totalItems, 0);
  });

  test('mutations persist to storage', () {
    controller.addProduct(_product(1, price: 5.0));
    controller.increment(1);

    expect(storage.stored, hasLength(1));
    expect(storage.stored.single.quantity, 2);
  });

  test('clear wipes storage', () {
    controller.addProduct(_product(1));
    controller.clear();

    expect(storage.stored, isEmpty);
  });

  test('a new container restores state from storage', () {
    controller.addProduct(_product(1, price: 5.0));

    final freshContainer = ProviderContainer(
      overrides: [
        cartStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(freshContainer.dispose);

    final restored = freshContainer.read(cartControllerProvider);
    expect(restored.totalItems, 1);
    expect(restored.totalPrice, 5.0);
    expect(restored.items.single.product.id, 1);
  });

  test('build restores items persisted before creation', () {
    storage.saveItems([CartItem(product: _product(7, price: 3.0), quantity: 2)]);

    final freshContainer = ProviderContainer(
      overrides: [
        cartStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(freshContainer.dispose);

    final restored = freshContainer.read(cartControllerProvider);
    expect(restored.totalItems, 2);
    expect(restored.totalPrice, 6.0);
  });
}
