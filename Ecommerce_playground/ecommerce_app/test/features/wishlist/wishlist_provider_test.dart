import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/wishlist/data/storage/wishlist_storage.dart';
import 'package:ecommerce_app/features/wishlist/presentation/providers/wishlist_dependencies.dart';
import 'package:ecommerce_app/features/wishlist/presentation/providers/wishlist_provider.dart';

class _InMemoryWishlistStorage implements WishlistStorage {
  List<Product> stored = [];

  @override
  void clear() => stored = [];

  @override
  List<Product> readProducts() => List.of(stored);

  @override
  void saveProducts(List<Product> products) => stored = List.of(products);
}

Product _product(int id) {
  return Product.fromJson({
    'id': id,
    'title': 'Product $id',
    'price': 10.0,
    'rating': 4.0,
  });
}

void main() {
  late ProviderContainer container;
  late WishlistController controller;
  late _InMemoryWishlistStorage storage;

  setUp(() {
    storage = _InMemoryWishlistStorage();
    container = ProviderContainer(
      overrides: [
        wishlistStorageProvider.overrideWithValue(storage),
      ],
    );
    controller = container.read(wishlistControllerProvider.notifier);
    addTearDown(container.dispose);
  });

  test('starts empty', () {
    expect(controller.state, isEmpty);
    expect(controller.isWishlisted(1), isFalse);
  });

  test('toggle adds a product', () {
    controller.toggle(_product(1));

    expect(controller.state, hasLength(1));
    expect(controller.isWishlisted(1), isTrue);
  });

  test('toggle removes an existing product', () {
    controller.toggle(_product(1));
    controller.toggle(_product(1));

    expect(controller.state, isEmpty);
    expect(controller.isWishlisted(1), isFalse);
  });

  test('toggle supports multiple products and dedupes by id', () {
    controller.toggle(_product(1));
    controller.toggle(_product(2));
    controller.toggle(_product(1));

    expect(controller.state, hasLength(1));
    expect(controller.isWishlisted(2), isTrue);
  });

  test('remove deletes only the given product', () {
    controller.toggle(_product(1));
    controller.toggle(_product(2));

    controller.remove(1);

    expect(controller.state, hasLength(1));
    expect(controller.state.single.id, 2);
  });

  test('clear empties the wishlist', () {
    controller.toggle(_product(1));

    controller.clear();

    expect(controller.state, isEmpty);
    expect(storage.stored, isEmpty);
  });

  test('mutations persist to storage', () {
    controller.toggle(_product(3));

    expect(storage.stored, hasLength(1));
    expect(storage.stored.single.id, 3);
  });

  test('a new container restores state from storage', () {
    controller.toggle(_product(4));

    final freshContainer = ProviderContainer(
      overrides: [
        wishlistStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(freshContainer.dispose);

    final restored = freshContainer.read(wishlistControllerProvider);
    expect(restored, hasLength(1));
    expect(restored.single.id, 4);
  });

  test('build restores items persisted before creation', () {
    storage.saveProducts([_product(9)]);

    final freshContainer = ProviderContainer(
      overrides: [
        wishlistStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(freshContainer.dispose);

    final restored = freshContainer.read(wishlistControllerProvider);
    expect(restored.single.id, 9);
  });
}
