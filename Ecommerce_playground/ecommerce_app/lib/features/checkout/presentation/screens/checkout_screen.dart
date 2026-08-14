import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/payment_method.dart';
import '../providers/order_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();

  PaymentMethod _paymentMethod = PaymentMethod.cashOnDelivery;
  bool _isPlacing = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPlacing = true);
    final order = await ref.read(orderControllerProvider.notifier).placeOrder(
          PlaceOrderParams(
            fullName: _fullNameController.text,
            phone: _phoneController.text,
            address: _addressController.text,
            city: _cityController.text,
            state: _stateController.text,
            zip: _zipController.text,
            paymentMethod: _paymentMethod,
          ),
        );
    if (!mounted) return;
    context.go(AppRoutes.orderSuccessFor(order.id));
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
    final palette = AppPalette.of(context);
    final text = AppTextStyles.of(context);

    if (cart.items.isEmpty) {
      return Scaffold(
        backgroundColor: palette.background,
        appBar: AppBar(title: const Text('Checkout')),
        body: const EmptyView(
          icon: Icons.shopping_bag_outlined,
          title: 'Your cart is empty',
          subtitle: 'Add something to your cart before checking out.',
        ),
      );
    }

    final subtotal = Order.subtotalFor(cart.items);
    final shipping = Order.shippingFor(subtotal);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _SectionHeader(title: 'Shipping details', icon: Icons.location_on_outlined),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fullNameController,
              enabled: !_isPlacing,
              decoration: const InputDecoration(labelText: 'Full name'),
              textInputAction: TextInputAction.next,
              validator: (value) => _required(value, 'Enter your full name'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              enabled: !_isPlacing,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: (value) {
                final required = _required(value, 'Enter your phone number');
                if (required != null) return required;
                final digits = value!.replaceAll(RegExp(r'\D'), '');
                if (digits.length < 7) return 'Enter a valid phone number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              enabled: !_isPlacing,
              decoration: const InputDecoration(labelText: 'Address'),
              textInputAction: TextInputAction.next,
              validator: (value) => _required(value, 'Enter your address'),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _cityController,
                    enabled: !_isPlacing,
                    decoration: const InputDecoration(labelText: 'City'),
                    textInputAction: TextInputAction.next,
                    validator: (value) => _required(value, 'Enter your city'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    enabled: !_isPlacing,
                    decoration: const InputDecoration(labelText: 'State (optional)'),
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _zipController,
              enabled: !_isPlacing,
              decoration: const InputDecoration(labelText: 'ZIP code (optional)'),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 28),
            _SectionHeader(title: 'Payment method', icon: Icons.credit_card_outlined),
            const SizedBox(height: 12),
            for (final method in PaymentMethod.values) ...[
              _PaymentTile(
                method: method,
                selected: _paymentMethod == method,
                enabled: !_isPlacing,
                onTap: () => setState(() => _paymentMethod = method),
              ),
              const SizedBox(height: 8),
            ],
            if (_paymentMethod.requiresCardFields) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _cardNumberController,
                enabled: !_isPlacing,
                decoration: const InputDecoration(labelText: 'Card number'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
                  if (digits.length < 12) return 'Enter a valid card number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cardExpiryController,
                      enabled: !_isPlacing,
                      decoration: const InputDecoration(labelText: 'Expiry (MM/YY)'),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(value)) {
                          return 'Use MM/YY';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cardCvvController,
                      enabled: !_isPlacing,
                      decoration: const InputDecoration(labelText: 'CVV'),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      validator: (value) {
                        final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
                        if (digits.length < 3) return 'Invalid CVV';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'This is a demo checkout - no payment is processed.',
                style: text.label.copyWith(fontSize: 12),
              ),
            ],
            const SizedBox(height: 28),
            _SectionHeader(title: 'Order summary', icon: Icons.receipt_long_outlined),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.border),
              ),
              child: Column(
                children: [
                  for (final item in cart.items) _SummaryItemRow(item: item),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  _SummaryLine(label: 'Subtotal', value: '\$${subtotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _SummaryLine(
                    label: 'Shipping',
                    value: shipping == 0
                        ? 'FREE'
                        : '\$${shipping.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: text.heading),
                      Text(
                        '\$${(subtotal + shipping).toStringAsFixed(2)}',
                        style: text.heading.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _CheckoutBar(
        total: subtotal + shipping,
        isPlacing: _isPlacing,
        onPressed: _isPlacing ? null : _placeOrder,
      ),
    );
  }

  String? _required(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: palette.ink),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.of(context).heading),
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? palette.surface : palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? palette.ink : palette.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              method.icon,
              size: 22,
              color: selected ? palette.ink : palette.muted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                method.label,
                style: AppTextStyles.of(context).body.copyWith(
                      color: selected ? palette.ink : palette.inkSoft,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 20,
              color: selected ? palette.ink : palette.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItemRow extends StatelessWidget {
  const _SummaryItemRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final text = AppTextStyles.of(context);
    final product = item.product;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.thumbnail,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                width: 40,
                height: 40,
                color: palette.border,
                child: Icon(
                  Icons.image_outlined,
                  size: 20,
                  color: palette.muted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.body.copyWith(color: palette.ink, fontSize: 14),
            ),
          ),
          Text('x${item.quantity}', style: text.label),
          const SizedBox(width: 12),
          Text(
            '\$${item.lineTotal.toStringAsFixed(2)}',
            style: text.price.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final text = AppTextStyles.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: text.body),
        Text(value, style: text.body.copyWith(color: palette.ink)),
      ],
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.total,
    required this.isPlacing,
    required this.onPressed,
  });

  final double total;
  final bool isPlacing;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final text = AppTextStyles.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
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
                  Text('Total', style: text.label),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: text.heading.copyWith(fontSize: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: onPressed,
                child: isPlacing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}