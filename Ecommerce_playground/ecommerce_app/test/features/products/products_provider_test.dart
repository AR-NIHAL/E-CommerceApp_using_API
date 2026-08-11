import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app/features/products/domain/entities/category.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/products/domain/repositories/products_repository.dart';
import 'package:ecommerce_app/features/products/presentation/providers/products_dependencies.dart';
import 'package:ecommerce_app/features/products/presentation/providers/products_provider.dart';

class _FakeProductsRepository implements ProductsRepository {
  final calls = <String>[];

  @override
  Future<ProductsPage> getProducts({
    int limit = 20,
    int skip = 0,
    String? category,
    String? query,
  }) async {
    calls.add('cat=$category,q=$query,skip=$skip');
    final base = skip + 1;
    final products = List.generate(
      limit,
      (i) => Product.fromJson({
        'id': base + i,
        'title': 'P${base + i}',
        'price': (base + i).toDouble(),
        'rating': (base + i) % 5 == 0 ? 5.0 : (base + i) % 5,
      }),
    );
    return ProductsPage(
      products: products,
      total: 45,
      hasMore: skip + products.length < 45,
    );
  }

  @override
  Future<List<Category>> getCategories() async => [];

  @override
  Future<Product> getProduct(int id) async => _product(id);
}

Product _product(int id) {
  return Product.fromJson({
    'id': id,
    'title': 'P$id',
    'price': id.toDouble(),
    'rating': id % 5 == 0 ? 5.0 : id % 5,
  });
}

Future<void> _waitForLoad(
  ProviderContainer container, {
  int timeoutMs = 3000,
}) async {
  final controller = container.read(productsControllerProvider.notifier);
  final deadline = DateTime.now().add(Duration(milliseconds: timeoutMs));
  while (controller.state.isLoading) {
    if (DateTime.now().isAfter(deadline)) {
      throw StateError('Timed out waiting for products load');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  late ProviderContainer container;
  late _FakeProductsRepository repository;

  setUp(() {
    repository = _FakeProductsRepository();
    container = ProviderContainer(
      overrides: [
        productsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  test('build loads the first page', () async {
    final controller = container.read(productsControllerProvider.notifier);
    await _waitForLoad(container);

    final state = controller.state;
    expect(state.products, hasLength(20));
    expect(state.isLoading, isFalse);
    expect(state.hasMore, isTrue);
    expect(repository.calls, contains('cat=null,q=null,skip=0'));
  });

  test('selectCategory reloads with the category', () async {
    final controller = container.read(productsControllerProvider.notifier);
    await _waitForLoad(container);

    await controller.selectCategory('beauty');
    await _waitForLoad(container);

    expect(controller.state.category, 'beauty');
    expect(repository.calls, contains('cat=beauty,q=null,skip=0'));
  });

  test('loadMore appends the next page', () async {
    final controller = container.read(productsControllerProvider.notifier);
    await _waitForLoad(container);

    await controller.loadMore();

    expect(controller.state.products, hasLength(40));
    expect(repository.calls, contains('cat=null,q=null,skip=20'));
  });

  test('setSort reorders products by price', () async {
    final controller = container.read(productsControllerProvider.notifier);
    await _waitForLoad(container);

    controller.setSort(ProductSort.priceLowToHigh);

    final prices = controller.state.products.map((p) => p.price).toList();
    expect(prices, orderedEquals([...prices]..sort()));
  });

  test('setSort reorders by rating descending', () async {
    final controller = container.read(productsControllerProvider.notifier);
    await _waitForLoad(container);

    controller.setSort(ProductSort.rating);

    final ratings = controller.state.products.map((p) => p.rating).toList();
    expect(ratings, orderedEquals([...ratings]..sort((a, b) => b.compareTo(a))));
  });
}
