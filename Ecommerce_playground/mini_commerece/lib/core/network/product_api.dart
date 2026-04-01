import 'package:mini_commerece/features/model/product_model.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';

class ProductApi {
  Future<List<Product>> fetchProducts() async {
    final res = await DioClient.dio.get(ApiEndpoints.products);

    final data = res.data as Map<String, dynamic>;
    final parsed = ProductListResponse.fromJson(data);

    return parsed.products;
  }
}
