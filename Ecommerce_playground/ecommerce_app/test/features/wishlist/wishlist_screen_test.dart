import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app/app/theme/app_theme.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/wishlist/data/storage/wishlist_storage.dart';
import 'package:ecommerce_app/features/wishlist/presentation/providers/wishlist_dependencies.dart';
import 'package:ecommerce_app/features/wishlist/presentation/screens/wishlist_screen.dart';

class _InMemoryWishlistStorage implements WishlistStorage {
  List<Product> stored = [];

  @override
  void clear() => stored = [];

  @override
  List<Product> readProducts() => List.of(stored);

  @override
  void saveProducts(List<Product> products) => stored = List.of(products);
}

Product _product(int id) {
  return Product.fromJson({
    'id': id,
    'title': 'Product $id',
    'price': 10.0,
    'rating': 4.0,
    'thumbnail': 'https://example.com/$id.jpg',
  });
}

void main() {
  late _InMemoryWishlistStorage storage;

  setUp(() {
    storage = _InMemoryWishlistStorage();
  });

  Future<void> pumpWishlist(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wishlistStorageProvider.overrideWithValue(storage),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const WishlistScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows empty state when there are no favorites', (tester) async {
    await pumpWishlist(tester);

    expect(find.text('No favorites yet'), findsOneWidget);
  });

  testWidgets('renders saved products in the grid', (tester) async {
    storage.saveProducts([_product(1), _product(2)]);

    await pumpWishlist(tester);

    expect(find.text('Product 1'), findsOneWidget);
    expect(find.text('Product 2'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(2));
  });

  testWidgets('tapping the heart removes a product', (tester) async {
    storage.saveProducts([_product(1), _product(2)]);

    await pumpWishlist(tester);

    await tester.tap(find.byIcon(Icons.favorite).first);
    await tester.pumpAndSettle();

    expect(storage.stored, hasLength(1));
    expect(storage.stored.single.id, 2);
    expect(find.text('Product 1'), findsNothing);
  });

  testWidgets('removing the last product shows the empty state', (tester) async {
    storage.saveProducts([_product(1)]);

    await pumpWishlist(tester);

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();

    expect(find.text('No favorites yet'), findsOneWidget);
    expect(storage.stored, isEmpty);
  });
}
