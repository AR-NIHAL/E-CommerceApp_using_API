import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/entities/order.dart';
import '../providers/order_provider.dart';

class OrderSuccessScreen extends ConsumerWidget {
  const OrderSuccessScreen({super.key, required this.orderId});

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
    final text = AppTextStyles.of(context);

    if (order == null) {
      return Scaffold(
        backgroundColor: palette.background,
        appBar: AppBar(),
        body: ErrorView(
          message: 'Order not found.',
          onRetry: () => context.go(AppRoutes.home),
        ),
      );
    }

    final placedDate =
        '${order.placedAt.day}/${order.placedAt.month}/${order.placedAt.year}';

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: palette.rating.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded, size: 56, color: palette.rating),
              ),
              const SizedBox(height: 24),
              Text('Order placed!', style: text.display),
              const SizedBox(height: 12),
              Text(
                'Your order $orderId was placed on $placedDate. '
                'A confirmation has been sent to you.',
                style: text.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total paid', style: text.body),
                    Text(
                      '\$${order.total.toStringAsFixed(2)}',
                      style: text.heading.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text('Continue shopping'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go(AppRoutes.orderHistory),
                child: const Text('View order history'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}