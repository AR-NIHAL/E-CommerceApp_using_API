class ApiEndpoints {
  static const String baseUrl = 'https://dummyjson.com';
  static const String products = '/products';

  static String productDetails(int id) => '/products/$id';
}
