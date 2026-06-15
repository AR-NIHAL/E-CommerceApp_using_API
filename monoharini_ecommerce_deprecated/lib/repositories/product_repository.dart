import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ProductRepository {
  final Dio dio;

  ProductRepository(this.dio);

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await dio.get('/products');

      final data = response.data;

      if (data is Map<String, dynamic>) {
        final productsList = data['products'];

        if (productsList is List) {
          return productsList
              .map((item) => ProductModel.fromJson(item))
              .toList();
        }
      }

      throw Exception('Unexpected response format');
    } on DioException catch (e) {
      throw Exception('Failed to load products: ${e.message}');
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }
}
