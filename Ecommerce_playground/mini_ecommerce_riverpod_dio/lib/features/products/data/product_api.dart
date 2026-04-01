import 'package:dio/dio.dart';
import 'product_models.dart';

class ProductApi {
  ProductApi(this._dio);

  final Dio _dio;

  Future<ProductsResponse> fetchProducts({
    int limit = 20,
    int skip = 0,
  }) async {
    // DummyJSON docs: default 30; limit/skip দিয়ে paginate :contentReference[oaicite:6]{index=6}
    final res = await _dio.get('/products', queryParameters: {
      'limit': limit,
      'skip': skip,
    });

    return ProductsResponse.fromJson(res.data as Map<String, dynamic>);
  }
}