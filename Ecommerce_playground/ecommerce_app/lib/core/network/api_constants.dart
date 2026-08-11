abstract final class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = 'https://dummyjson.com';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const String products = '/products';
  static const String productCategories = '/products/categories';
  static const String productSearch = '/products/search';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
}
