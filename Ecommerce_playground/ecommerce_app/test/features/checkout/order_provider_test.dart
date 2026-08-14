import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app/features/cart/data/storage/cart_storage.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/presentation/providers/cart_dependencies.dart';
import 'package:ecommerce_app/features/checkout/data/storage/order_storage.dart';
import 'package:ecommerce_app/features/checkout/domain/entities/order.dart';
import 'package:ecommerce_app/features/checkout/domain/entities/payment_method.dart';
import 'package:ecommerce_app/features/checkout/presentation/providers/order_dependencies.dart';
import 'package:ecommerce_app/features/checkout/presentation/providers/order_provider.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

class _FakeCartStorage implements CartStorage {
  _FakeCartStorage(this.items);

  List<CartItem> items;

  @override
  List<CartItem> readItems() => items;

  @override
  void saveItems(List<CartItem> items) {
    this.items = items;
  }

  @override
  void clear() {
    items = [];
  }
}

class _FakeOrderStorage implements OrderStorage {
  List<Order> orders = [];

  @override
  List<Order> readOrders() => orders;

  @override
  void saveOrders(List<Order> orders) {
    this.orders = orders;
  }

  @override
  void clear() {
    orders = [];
  }
}

Product _product(int id, {double price = 100.0, double discount = 25.0}) {
  return Product.fromJson({
    'id': id,
    'title': 'Product $id',
    'price': price,
    if (discount > 0) 'discountPercentage': discount,
  });
}

PlaceOrderParams _params() {
  return const PlaceOrderParams(
    fullName: 'Jane Doe',
    phone: '1234567890',
    address: '1 Main St',
    city: 'Springfield',
    state: 'IL',
    zip: '62701',
    paymentMethod: PaymentMethod.card,
  );
}

void main() {
  late ProviderContainer container;
  late _FakeCartStorage cartStorage;
  late _FakeOrderStorage orderStorage;

  setUp(() {
    cartStorage = _FakeCartStorage([
      CartItem(product: _product(1), quantity: 1),
      CartItem(product: _product(2), quantity: 1),
    ]);
    orderStorage = _FakeOrderStorage();
    container = ProviderContainer(
      overrides: [
        cartStorageProvider.overrideWithValue(cartStorage),
        orderStorageProvider.overrideWithValue(orderStorage),
      ],
    );
    addTearDown(container.dispose);
  });

  test('placeOrder creates an order, persists it and clears the cart', () async {
    final controller = container.read(orderControllerProvider.notifier);

    final order = await controller.placeOrder(_params());

    expect(order.id, startsWith('ORD-'));
    expect(order.fullName, 'Jane Doe');
    expect(order.items, hasLength(2));
    expect(order.paymentMethod, PaymentMethod.card);
    expect(order.subtotal, 150.0);
    expect(order.shipping, 0.0);
    expect(order.total, 150.0);

    expect(orderStorage.orders, hasLength(1));
    expect(orderStorage.orders.single.id, order.id);
    expect(cartStorage.items, isEmpty);
    expect(controller.state, hasLength(1));
  });

  test('placeOrder applies shipping fee under the free threshold', () async {
    cartStorage.items = [CartItem(product: _product(9, price: 10, discount: 0), quantity: 1)];
    final controller = container.read(orderControllerProvider.notifier);

    final order = await controller.placeOrder(_params());

    expect(order.subtotal, 10.0);
    expect(order.shipping, Order.shippingFee);
    expect(order.total, 10.0 + Order.shippingFee);
  });

  test('orderById returns the matching order', () async {
    final controller = container.read(orderControllerProvider.notifier);
    final order = await controller.placeOrder(_params());

    expect(controller.orderById(order.id), same(order));
    expect(controller.orderById('ORD-000000'), isNull);
  });
}