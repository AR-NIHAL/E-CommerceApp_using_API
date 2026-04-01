import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_commerece/features/home/cart_provider.dart';
import 'package:mini_commerece/widgets/cart_item_title.dart';
import 'package:mini_commerece/widgets/cart_summary_bar.dart';

import '../../../core/theme/app_text_styles.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(cartProvider.notifier).clear(),
              child: const Text('Clear'),
            ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: cart.items.isEmpty
                ? Center(
                    child: Text(
                      'Your cart is empty',
                      style: AppTextStyles.h1,
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 110),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return CartItemTile(
                        item: item,
                        onIncrease: () => ref
                            .read(cartProvider.notifier)
                            .increase(item.product.id),
                        onDecrease: () => ref
                            .read(cartProvider.notifier)
                            .decrease(item.product.id),
                        onRemove: () => ref
                            .read(cartProvider.notifier)
                            .remove(item.product.id),
                      );
                    },
                  ),
          ),

          // Summary bar
          if (cart.items.isNotEmpty)
            CartSummaryBar(
              totalItems: cart.totalItems,
              totalPrice: cart.totalPrice,
              onCheckout: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Checkout coming soon')),
                );
              },
            ),
        ],
      ),
    );
  }
}
