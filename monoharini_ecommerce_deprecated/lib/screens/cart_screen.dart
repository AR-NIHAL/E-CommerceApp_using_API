import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monoharini_ecommerce/screens/checkout_screen.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalPrice = ref.watch(cartTotalPriceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Cart',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(cartProvider.notifier).clearCart();
              },
              child: const Text(
                'Clear',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? const _EmptyCartView()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];

                      return CartItemTile(
                        item: item,
                        onIncrease: () {
                          ref
                              .read(cartProvider.notifier)
                              .increaseQuantity(item.id);
                        },
                        onDecrease: () {
                          ref
                              .read(cartProvider.notifier)
                              .decreaseQuantity(item.id);
                        },
                        onRemove: () {
                          ref
                              .read(cartProvider.notifier)
                              .removeFromCart(item.id);
                        },
                      );
                    },
                  ),
                ),
                _CartSummarySection(totalPrice: totalPrice),
              ],
            ),
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 18),
            Text(
              'Your cart is empty',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add some products to see them here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSummarySection extends StatelessWidget {
  final double totalPrice;

  const _CartSummarySection({required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    const shippingFee = 0.0;
    final grandTotal = totalPrice + shippingFee;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SummaryRow(
              title: 'Subtotal',
              value: '\$${totalPrice.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              title: 'Shipping',
              value: '\$${shippingFee.toStringAsFixed(2)}',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            _SummaryRow(
              title: 'Total',
              value: '\$${grandTotal.toStringAsFixed(2)}',
              isBold: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(
                  //     content: Text('Checkout feature will be added later'),
                  //   ),
                  // );

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B3168),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isBold;

  const _SummaryRow({
    required this.title,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontFamily: 'Poppins',
      fontSize: isBold ? 16 : 14,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
      color: Colors.black,
    );

    return Row(
      children: [
        Text(title, style: textStyle),
        const Spacer(),
        Text(value, style: textStyle),
      ],
    );
  }
}
