import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../data/storage/order_storage.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/payment_method.dart';
import 'order_dependencies.dart';

part 'order_provider.g.dart';

class PlaceOrderParams {
  const PlaceOrderParams({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    this.state,
    this.zip,
    required this.paymentMethod,
  });

  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String? state;
  final String? zip;
  final PaymentMethod paymentMethod;
}

@Riverpod(keepAlive: true)
class OrderController extends _$OrderController {
  OrderStorage get _storage => ref.read(orderStorageProvider);

  @override
  List<Order> build() {
    return _storage.readOrders();
  }

  Order? orderById(String id) {
    for (final order in state) {
      if (order.id == id) return order;
    }
    return null;
  }

  Future<Order> placeOrder(PlaceOrderParams params) async {
    final cart = ref.read(cartControllerProvider);
    final items = List<CartItem>.from(cart.items);
    final subtotal = Order.subtotalFor(items);
    final shipping = Order.shippingFor(subtotal);

    final order = Order(
      id: _generateId(),
      placedAt: DateTime.now(),
      items: items,
      fullName: params.fullName.trim(),
      phone: params.phone.trim(),
      address: params.address.trim(),
      city: params.city.trim(),
      state: params.state?.trim().isEmpty ?? true ? null : params.state!.trim(),
      zip: params.zip?.trim().isEmpty ?? true ? null : params.zip!.trim(),
      paymentMethod: params.paymentMethod,
      subtotal: subtotal,
      shipping: shipping,
      total: subtotal + shipping,
    );

    _setState([order, ...state]);
    ref.read(cartControllerProvider.notifier).clear();
    return order;
  }

  void clear() {
    _setState(const []);
  }

  String _generateId() {
    final random = Random();
    final code = List.generate(6, (_) => random.nextInt(10)).join();
    return 'ORD-$code';
  }

  void _setState(List<Order> next) {
    state = next;
    _storage.saveOrders(next);
  }
}