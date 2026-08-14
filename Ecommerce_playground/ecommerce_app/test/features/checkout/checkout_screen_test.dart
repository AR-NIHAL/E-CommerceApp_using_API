import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ecommerce_app/app/theme/app_theme.dart';
import 'package:ecommerce_app/features/cart/data/storage/cart_storage.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/presentation/providers/cart_dependencies.dart';
import 'package:ecommerce_app/features/checkout/data/storage/order_storage.dart';
import 'package:ecommerce_app/features/checkout/domain/entities/order.dart';
import 'package:ecommerce_app/features/checkout/presentation/providers/order_dependencies.dart';
import 'package:ecommerce_app/features/checkout/presentation/screens/checkout_screen.dart';
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

Product _product() {
  return Product.fromJson({
    'id': 1,
    'title': 'Fancy Watch',
    'price': 100.0,
    'discountPercentage': 25.0,
    'thumbnail': 'https://example.com/thumb.jpg',
  });
}

Widget _app(_FakeCartStorage cartStorage, _FakeOrderStorage orderStorage) {
  final router = GoRouter(
    initialLocation: '/checkout',
    routes: [
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/order-success/:id',
        builder: (context, state) => Text('SUCCESS ${state.pathParameters['id']}'),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      cartStorageProvider.overrideWithValue(cartStorage),
      orderStorageProvider.overrideWithValue(orderStorage),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

void main() {
  late _FakeCartStorage cartStorage;
  late _FakeOrderStorage orderStorage;

  setUp(() {
    cartStorage = _FakeCartStorage([
      CartItem(product: _product(), quantity: 1),
    ]);
    orderStorage = _FakeOrderStorage();
  });

  testWidgets('renders items, shipping and totals', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(cartStorage, orderStorage));

    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Fancy Watch'), findsOneWidget);
    expect(find.text('Place Order'), findsOneWidget);
    // price 100 with 25% off = 75, subtotal 75 >= 50 => free shipping:
    // "$75.00" appears for the item line total, subtotal, summary total
    // and bottom-bar total.
    expect(find.text('\$75.00'), findsNWidgets(4));
    expect(find.text('FREE'), findsOneWidget);
  });

  testWidgets('shows validation errors on empty submit', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(cartStorage, orderStorage));

    final placeOrderButton = find.widgetWithText(ElevatedButton, 'Place Order');
    await tester.tap(placeOrderButton);
    await tester.pump();

    expect(find.text('Enter your full name'), findsOneWidget);
    expect(find.text('Enter your phone number'), findsOneWidget);
    expect(find.text('Enter your address'), findsOneWidget);
    expect(find.text('Enter your city'), findsOneWidget);
  });

  testWidgets('card fields appear when card is selected', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(cartStorage, orderStorage));

    expect(find.text('Card number'), findsNothing);

    await tester.tap(find.text('Debit / Credit Card'));
    await tester.pump();

    expect(find.text('Card number'), findsOneWidget);
    expect(find.text('Expiry (MM/YY)'), findsOneWidget);
    expect(find.text('CVV'), findsOneWidget);
  });

  testWidgets('placing an order clears the cart and navigates to success',
      (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(cartStorage, orderStorage));

    await tester.enterText(find.widgetWithText(TextFormField, 'Full name'), 'Jane Doe');
    await tester.enterText(find.widgetWithText(TextFormField, 'Phone'), '1234567890');
    await tester.enterText(find.widgetWithText(TextFormField, 'Address'), '1 Main St');
    await tester.enterText(find.widgetWithText(TextFormField, 'City'), 'Springfield');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Place Order'));
    await tester.pumpAndSettle();

    expect(find.textContaining('SUCCESS'), findsOneWidget);
    expect(cartStorage.items, isEmpty);
    expect(orderStorage.orders, hasLength(1));
  });
}