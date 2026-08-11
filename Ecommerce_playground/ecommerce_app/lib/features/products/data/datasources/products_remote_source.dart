import 'package:dio/dio.dart';

import '../../../../core/errors/exception_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_constants.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';

class ProductsRemoteDataSource {
  const ProductsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ProductsPage> getProducts({
    required int limit,
    required int skip,
    String? category,
    String? query,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'skip': skip,
        if (query != null && query.isNotEmpty) 'q': query,
      };

      final String path;
      if (query != null && query.isNotEmpty) {
        path = ApiConstants.productSearch;
      } else if (category != null && category.isNotEmpty) {
        path = '${ApiConstants.products}/category/$category';
      } else {
        path = ApiConstants.products;
      }

      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParams,
      );

      final data = response.data!;
      final products = (data['products'] as List<dynamic>? ?? [])
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
      final total = data['total'] as int? ?? products.length;

      return ProductsPage(
        products: products,
        total: total,
        hasMore: skip + products.length < total,
      );
    } on DioException catch (error) {
      throw FailureMapper.fromDio(error);
    } catch (_) {
      throw const UnknownFailure();
    }
  }

  Future<Product> getProduct(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${ApiConstants.products}/$id',
      );
      return Product.fromJson(response.data!);
    } on DioException catch (error) {
      throw FailureMapper.fromDio(error);
    } catch (_) {
      throw const UnknownFailure();
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiConstants.productCategories,
      );
      return response.data!
          .map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw FailureMapper.fromDio(error);
    } catch (_) {
      throw const UnknownFailure();
    }
  }
}
