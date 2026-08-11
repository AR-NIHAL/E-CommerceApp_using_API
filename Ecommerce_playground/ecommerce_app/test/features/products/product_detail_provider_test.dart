import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app/features/products/domain/entities/category.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/products/domain/repositories/products_repository.dart';
import 'package:ecommerce_app/features/products/presentation/providers/product_detail_provider.dart';
import 'package:ecommerce_app/features/products/presentation/providers/products_dependencies.dart';

class _FakeProductsRepository implements ProductsRepository {
  _FakeProductsRepository({this.failOnce = false});

  final bool failOnce;
  bool _hasFailed = false;

  @override
  Future<ProductsPage> getProducts({
    int limit = 20,
    int skip = 0,
    String? category,
    String? query,
  }) async {
    return const ProductsPage(products: [], total: 0, hasMore: false);
  }

  @override
  Future<List<Category>> getCategories() async => [];

  @override
  Future<Product> getProduct(int id) async {
    if (failOnce && !_hasFailed) {
      _hasFailed = true;
      throw Exception('boom');
    }
    return Product.fromJson({
      'id': id,
      'title': 'Product $id',
      'description': 'A great product',
      'category': 'beauty',
      'price': 100.0,
      'discountPercentage': 20.0,
      'rating': 4.5,
      'stock': 12,
      'brand': 'Acme',
      'thumbnail': 'https://example.com/thumb.jpg',
      'images': ['https://example.com/1.jpg', 'https://example.com/2.jpg'],
    });
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

  test('loads the product for the requested id', () async {
    final state = await container.read(productDetailProvider(7).future);

    expect(state.id, 7);
    expect(state.title, 'Product 7');
    expect(state.hasDiscount, isTrue);
    expect(state.discountPrice, closeTo(80.0, 0.001));
  });

  test('keeps distinct states per product id', () async {
    final first = await container.read(productDetailProvider(1).future);
    final second = await container.read(productDetailProvider(2).future);

    expect(first.id, 1);
    expect(second.id, 2);
    expect(first, isNot(second));
  });

  test('invalidating a family member refetches it', () async {
    final before = await container.read(productDetailProvider(1).future);
    expect(before.title, 'Product 1');

    container.invalidate(productDetailProvider(1));
    final after = await container.read(productDetailProvider(1).future);
    expect(after.title, 'Product 1');
  });
}
