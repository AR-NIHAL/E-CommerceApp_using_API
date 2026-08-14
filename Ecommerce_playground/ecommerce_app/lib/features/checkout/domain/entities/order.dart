import '../../../cart/domain/entities/cart_item.dart';
import 'payment_method.dart';

class Order {
  const Order({
    required this.id,
    required this.placedAt,
    required this.items,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
    required this.paymentMethod,
    required this.subtotal,
    required this.shipping,
    required this.total,
  });

  static const double freeShippingThreshold = 50;
  static const double shippingFee = 4.99;

  final String id;
  final DateTime placedAt;
  final List<CartItem> items;
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String? state;
  final String? zip;
  final PaymentMethod paymentMethod;
  final double subtotal;
  final double shipping;
  final double total;

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  String get shippingLabel => shipping == 0 ? 'FREE' : '\$${shipping.toStringAsFixed(2)}';

  static double shippingFor(double subtotal) {
    if (subtotal >= freeShippingThreshold) return 0;
    return shippingFee;
  }

  static double subtotalFor(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + item.lineTotal);
  }
}