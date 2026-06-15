import 'package:dio/dio.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final Dio dio;

  CategoryRepository(this.dio);

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await dio.get('/products/categories');

      final data = response.data;

      if (data is List) {
        return data.map((item) => CategoryModel.fromApi(item)).toList();
      }

      throw Exception('Unexpected response format');
    } on DioException catch (e) {
      throw Exception('Failed to load categories: ${e.message}');
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }
}
