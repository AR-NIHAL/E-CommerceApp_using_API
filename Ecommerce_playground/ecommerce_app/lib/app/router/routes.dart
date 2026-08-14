abstract final class AppRoutes {
  const AppRoutes._();

  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String shell = '/shell';
  static const String home = '/shell/home';
  static const String search = '/shell/search';
  static const String cart = '/shell/cart';
  static const String wishlist = '/shell/wishlist';
  static const String profile = '/shell/profile';
  static const String productDetail = '/product/:id';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success/:id';
  static const String orderHistory = '/order-history';
  static const String orderDetail = '/order-detail/:id';

  static String productDetailFor(int id) => '/product/$id';

  static String orderSuccessFor(String id) => '/order-success/$id';

  static String orderDetailFor(String id) => '/order-detail/$id';
}
