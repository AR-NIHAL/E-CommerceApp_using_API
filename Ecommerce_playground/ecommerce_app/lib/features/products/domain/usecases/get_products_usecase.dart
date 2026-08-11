import '../entities/category.dart';
import '../repositories/products_repository.dart';

class GetProductsParams {
  const GetProductsParams({
    this.limit = 20,
    this.skip = 0,
    this.category,
    this.query,
  });

  final int limit;
  final int skip;
  final String? category;
  final String? query;
}

class GetProductsUsecase {
  const GetProductsUsecase(this._repository);

  final ProductsRepository _repository;

  Future<ProductsPage> call(GetProductsParams params) {
    return _repository.getProducts(
      limit: params.limit,
      skip: params.skip,
      category: params.category,
      query: params.query,
    );
  }
}

class GetCategoriesUsecase {
  const GetCategoriesUsecase(this._repository);

  final ProductsRepository _repository;

  Future<List<Category>> call() => _repository.getCategories();
}
