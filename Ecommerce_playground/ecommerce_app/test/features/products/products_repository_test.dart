import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app/features/products/data/datasources/products_remote_source.dart';
import 'package:ecommerce_app/features/products/data/repositories/products_repository_impl.dart';
import 'package:ecommerce_app/features/products/domain/entities/category.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/products/domain/repositories/products_repository.dart';

class _FakeRemoteSource implements ProductsRemoteDataSource {
  final int total = 25;
  final calls = <String>[];

  @override
  Future<ProductsPage> getProducts({
    required int limit,
    required int skip,
    String? category,
    String? query,
  }) async {
    calls.add('limit=$limit,skip=$skip,cat=$category,q=$query');
    final products = List.generate(
      limit,
      (i) => Product.fromJson({
        'id': skip + i + 1,
        'title': 'Product ${skip + i + 1}',
        'price': 10.0,
      }),
    );
    return ProductsPage(
      products: products,
      total: total,
      hasMore: skip + products.length < total,
    );
  }

  @override
  Future<List<Category>> getCategories() async => [
        const Category(slug: 'beauty', name: 'Beauty'),
        const Category(slug: 'fragrances', name: 'Fragrances'),
      ];

  @override
  Future<Product> getProduct(int id) async => _product(id);
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
  late _FakeRemoteSource remote;
  late ProductsRepositoryImpl repository;

  setUp(() {
    remote = _FakeRemoteSource();
    repository = ProductsRepositoryImpl(remoteSource: remote);
  });

  test('getProducts returns a page with pagination metadata', () async {
    final page = await repository.getProducts(limit: 20, skip: 0);

    expect(page.products, hasLength(20));
    expect(page.total, 25);
    expect(page.hasMore, isTrue);
    expect(remote.calls, ['limit=20,skip=0,cat=null,q=null']);
  });

  test('hasMore is false on the last page', () async {
    final page = await repository.getProducts(limit: 20, skip: 20);

    expect(page.products, hasLength(20));
    expect(page.hasMore, isFalse);
  });

  test('category and query params are forwarded', () async {
    await repository.getProducts(
      limit: 10,
      skip: 0,
      category: 'beauty',
    );
    await repository.getProducts(limit: 10, skip: 0, query: 'phone');

    expect(remote.calls[0], 'limit=10,skip=0,cat=beauty,q=null');
    expect(remote.calls[1], 'limit=10,skip=0,cat=null,q=phone');
  });
}
