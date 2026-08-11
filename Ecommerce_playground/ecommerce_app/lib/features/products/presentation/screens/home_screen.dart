import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/product_card_shimmer.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/category_chips.dart';
import '../widgets/product_card.dart';
import '../widgets/product_search_bar.dart';
import '../widgets/sort_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productsControllerProvider);
    final controller = ref.read(productsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SwiftShop',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go(AppRoutes.cart),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: ProductSearchBar(),
            ),
            const CategoryChips(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Products',
                    style: AppTextStyles.heading,
                  ),
                  _SortButton(
                    sort: state.sort,
                    onTap: () => SortSheet.show(
                      context,
                      selected: state.sort,
                      onSelect: controller.setSort,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _buildBody(context, ref, state, controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ProductsState state,
      ProductsController controller) {
    if (state.isLoading) {
      return const _ProductGridShimmer();
    }

    if (state.error != null && state.products.isEmpty) {
      return ErrorView(message: state.error!, onRetry: controller.refresh);
    }

    if (state.products.isEmpty) {
      return Center(
        child: Text('No products found', style: AppTextStyles.body),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 400) {
            controller.loadMore();
          }
          return false;
        },
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.62,
          ),
          itemCount: state.products.length + (state.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.products.length) {
              return const ProductCardShimmer();
            }

            final product = state.products[index];
            return ProductCard(
              product: product,
              onTap: () => context.go(AppRoutes.productDetailFor(product.id)),
              onAddToCart: () =>
                  ref.read(cartControllerProvider.notifier).addProduct(product),
            );
          },
        ),
      ),
    );
  }
}

class _ProductGridShimmer extends StatelessWidget {
  const _ProductGridShimmer();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const ProductCardShimmer(),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({required this.sort, required this.onTap});

  final ProductSort sort;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.tune, size: 18),
      label: Text(_labelFor(sort)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  String _labelFor(ProductSort sort) {
    return switch (sort) {
      ProductSort.featured => 'Featured',
      ProductSort.priceLowToHigh => 'Lowest price',
      ProductSort.priceHighToLow => 'Highest price',
      ProductSort.rating => 'Top rated',
    };
  }
}
