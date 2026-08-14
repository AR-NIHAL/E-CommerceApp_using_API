import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/order.dart';
import '../providers/order_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Order? order;
    for (final o in ref.watch(orderControllerProvider)) {
      if (o.id == orderId) {
        order = o;
        break;
      }
    }
    final palette = AppPalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(title: const Text('Order details')),
      body: order == null
          ? ErrorView(
              message: 'Order not found.',
              onRetry: () {},
            )
          : _OrderDetailBody(order: order),
    );
  }
}

class _OrderDetailBody extends StatelessWidget {
  const _OrderDetailBody({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final text = AppTextStyles.of(context);
    final placedDate =
        '${order.placedAt.day}/${order.placedAt.month}/${order.placedAt.year} '
        '${order.placedAt.hour.toString().padLeft(2, '0')}:${order.placedAt.minute.toString().padLeft(2, '0')}';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.id, style: text.heading),
              const SizedBox(height: 4),
              Text('Placed on $placedDate', style: text.label.copyWith(fontSize: 12)),
              const SizedBox(height: 8),
              Text(order.paymentMethod.label, style: text.body),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Items', style: text.heading),
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
              for (final item in order.items) _OrderItemRow(item: item),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Shipping details', style: text.heading),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.fullName, style: text.body.copyWith(color: palette.ink)),
              const SizedBox(height: 2),
              Text(order.phone, style: text.body),
              const SizedBox(height: 2),
              Text(
                [
                  order.address,
                  order.city,
                  if (order.state != null) order.state!,
                  if (order.zip != null) order.zip!,
                ].join(', '),
                style: text.body,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Payment summary', style: text.heading),
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
              _SummaryLine(label: 'Subtotal', value: '\$${order.subtotal.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _SummaryLine(label: 'Shipping', value: order.shippingLabel),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: text.heading),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: text.heading.copyWith(fontSize: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

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