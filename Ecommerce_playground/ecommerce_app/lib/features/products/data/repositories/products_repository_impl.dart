import '../../domain/entities/category.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_source.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  const ProductsRepositoryImpl({required ProductsRemoteDataSource remoteSource})
      : _remoteSource = remoteSource;

  final ProductsRemoteDataSource _remoteSource;

  @override
  Future<ProductsPage> getProducts({
    int limit = 20,
    int skip = 0,
    String? category,
    String? query,
  }) {
    return _remoteSource.getProducts(
      limit: limit,
      skip: skip,
      category: category,
      query: query,
    );
  }

  @override
  Future<List<Category>> getCategories() {
    return _remoteSource.getCategories();
  }
}
