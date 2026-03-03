import 'package:mini_commerece/features/model/product_details_model.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';

class ProductDetailsApi {
  Future<ProductDetails> fetchDetails(int id) async {
    final res = await DioClient.dio.get(ApiEndpoints.productDetails(id));
    final data = res.data as Map<String, dynamic>;
    return ProductDetails.fromJson(data);
  }
}
