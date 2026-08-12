import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../providers/wishlist_provider.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(wishlistControllerProvider);

    return Scaffold(
      backgroundColor: AppPalette.of(context).background,
      appBar: AppBar(title: const Text('Wishlist')),
      body: products.isEmpty
          ? const EmptyView(
              icon: Icons.favorite_outline,
              title: 'No favorites yet',
              subtitle: 'Tap the heart on any product to save it here.',
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.62,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  isWishlisted: true,
                  onTap: () =>
                      context.go(AppRoutes.productDetailFor(product.id)),
                  onAddToCart: () => ref
                      .read(cartControllerProvider.notifier)
                      .addProduct(product),
                  onToggleWishlist: () => ref
                      .read(wishlistControllerProvider.notifier)
                      .toggle(product),
                );
              },
            ),
    );
  }
}
