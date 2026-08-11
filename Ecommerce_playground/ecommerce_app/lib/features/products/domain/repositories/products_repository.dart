import '../entities/category.dart';
import '../entities/product.dart';

class ProductsPage {
  const ProductsPage({
    required this.products,
    required this.total,
    required this.hasMore,
  });

  final List<Product> products;
  final int total;
  final bool hasMore;
}

abstract interface class ProductsRepository {
  Future<ProductsPage> getProducts({
    int limit,
    int skip,
    String? category,
    String? query,
  });

  Future<List<Category>> getCategories();
}
