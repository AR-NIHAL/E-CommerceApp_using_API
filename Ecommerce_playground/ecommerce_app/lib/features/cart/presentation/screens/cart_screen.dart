import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/entities/cart_item.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear cart'),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ref.read(cartControllerProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          if (cart.totalItems > 0)
            TextButton(
              onPressed: () => _confirmClear(context, ref),
              child: const Text('Clear all'),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? const EmptyView(
              icon: Icons.shopping_bag_outlined,
              title: 'Your cart is empty',
              subtitle: 'Browse the catalog and add something you like.',
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: cart.items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _CartItemTile(item: cart.items[index]);
                    },
                  ),
                ),
                _CartSummaryBar(cart: cart),
              ],
            ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  const _CartItemTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = item.product;

    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (direction) {
        ref.read(cartControllerProvider.notifier).removeItem(product.id);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.thumbnail,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  width: 72,
                  height: 72,
                  color: AppColors.border,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_outlined,
                    size: 28,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: AppTextStyles.body.copyWith(color: AppColors.ink),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${product.discountPrice.toStringAsFixed(2)}',
                    style: AppTextStyles.price,
                  ),
                ],
              ),
            ),
            _QuantityStepper(item: item),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends ConsumerWidget {
  const _QuantityStepper({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartControllerProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => notifier.decrement(item.product.id),
                icon: const Icon(Icons.remove, size: 16),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
              SizedBox(
                width: 24,
                child: Text(
                  '${item.quantity}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => notifier.increment(item.product.id),
                icon: const Icon(Icons.add, size: 16),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.lineTotal.toStringAsFixed(2),
          style: AppTextStyles.label.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class _CartSummaryBar extends StatelessWidget {
  const _CartSummaryBar({required this.cart});

  final CartState cart;

  void _onCheckout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Checkout is coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${cart.totalItems} item${cart.totalItems == 1 ? '' : 's'}',
                    style: AppTextStyles.label,
                  ),
                  Text(
                    '\$${cart.totalPrice.toStringAsFixed(2)}',
                    style: AppTextStyles.heading.copyWith(fontSize: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _onCheckout(context),
                child: const Text('Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
