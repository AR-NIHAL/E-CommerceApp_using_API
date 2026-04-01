import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  Future<List<String>> fetchCategories() async {
    final url = Uri.parse('https://dummyjson.com/products/category-list');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);

      return jsonData.map((item) => item.toString()).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<dynamic>> fetchProductsByCategory(String categoryName) async {
    final url = Uri.parse(
      'https://dummyjson.com/products/category/$categoryName',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      return jsonData['products'];
    } else {
      throw Exception('Failed to load category products');
    }
  }
}
