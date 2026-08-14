import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../domain/entities/order.dart';
import '../providers/order_provider.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderControllerProvider);
    final palette = AppPalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(title: const Text('Order history')),
      body: orders.isEmpty
          ? const EmptyView(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              subtitle: 'Your placed orders will appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _OrderHistoryTile(order: orders[index]),
            ),
    );
  }
}

class _OrderHistoryTile extends StatelessWidget {
  const _OrderHistoryTile({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final text = AppTextStyles.of(context);
    final placedDate =
        '${order.placedAt.day}/${order.placedAt.month}/${order.placedAt.year}';

    return InkWell(
      onTap: () => context.push(AppRoutes.orderDetailFor(order.id)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: palette.ink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.receipt_long_outlined, size: 22, color: palette.onAccent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.id,
                    style: text.body.copyWith(
                      color: palette.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$placedDate · ${order.totalItems} item${order.totalItems == 1 ? '' : 's'}',
                    style: text.label.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '\$${order.total.toStringAsFixed(2)}',
              style: text.price,
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 20, color: palette.muted),
          ],
        ),
      ),
    );
  }
}