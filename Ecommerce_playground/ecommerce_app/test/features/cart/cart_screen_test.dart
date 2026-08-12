import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app/app/theme/app_theme.dart';
import 'package:ecommerce_app/features/cart/data/storage/cart_storage.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/presentation/providers/cart_dependencies.dart';
import 'package:ecommerce_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

class _InMemoryCartStorage implements CartStorage {
  List<CartItem> stored = [];

  @override
  void clear() => stored = [];

  @override
  List<CartItem> readItems() => List.of(stored);

  @override
  void saveItems(List<CartItem> items) => stored = List.of(items);
}

Product _product(int id, {double price = 10.0}) {
  return Product.fromJson({
    'id': id,
    'title': 'Product $id',
    'price': price,
    'rating': 4.0,
    'thumbnail': 'https://example.com/$id.jpg',
  });
}

void main() {
  late _InMemoryCartStorage storage;

  setUp(() {
    storage = _InMemoryCartStorage();
  });

  Future<void> pumpCart(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartStorageProvider.overrideWithValue(storage),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const CartScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows empty state when the cart has no items', (tester) async {
    await pumpCart(tester);

    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.text('Checkout'), findsNothing);
  });

  testWidgets('renders items with prices and totals', (tester) async {
    storage.saveItems([
      CartItem(product: _product(1, price: 20.0), quantity: 2),
      CartItem(product: _product(2, price: 10.0), quantity: 1),
    ]);

    await pumpCart(tester);

    expect(find.text('Product 1'), findsOneWidget);
    expect(find.text('Product 2'), findsOneWidget);
    expect(find.text('\$20.00'), findsOneWidget);
    expect(find.text('\$10.00'), findsOneWidget);
    expect(find.text('3 items'), findsOneWidget);
    expect(find.text('\$50.00'), findsOneWidget);
    expect(find.text('Checkout'), findsOneWidget);
  });

  testWidgets('increment updates quantity and total', (tester) async {
    storage.saveItems([CartItem(product: _product(1, price: 10.0), quantity: 1)]);

    await pumpCart(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
    expect(find.text('2 items'), findsOneWidget);
    expect(find.text('\$20.00'), findsOneWidget);
  });

  testWidgets('decrement removes an item at quantity one', (tester) async {
    storage.saveItems([CartItem(product: _product(1, price: 10.0), quantity: 1)]);

    await pumpCart(tester);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();

    expect(find.text('Your cart is empty'), findsOneWidget);
  });

  testWidgets('swipe-to-delete removes an item', (tester) async {
    storage.saveItems([
      CartItem(product: _product(1), quantity: 1),
      CartItem(product: _product(2), quantity: 1),
    ]);

    await pumpCart(tester);

    await tester.drag(
      find.text('Product 1'),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Product 1'), findsNothing);
    expect(find.text('Product 2'), findsOneWidget);
  });

  testWidgets('clear all empties the cart after confirmation', (tester) async {
    storage.saveItems([CartItem(product: _product(1), quantity: 1)]);

    await pumpCart(tester);

    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(storage.readItems(), isEmpty);
  });
}
