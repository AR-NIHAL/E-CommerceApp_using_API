import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/products_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productsControllerProvider);
    final product = state.products.where((p) => p.id == productId).firstOrNull;

    return Scaffold(
      appBar: AppBar(),
      body: product == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(
                    product.thumbnail,
                    height: 200,
                    errorBuilder: (context, error, stack) => const Icon(
                      Icons.image_outlined,
                      size: 64,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      product.title,
                      style: AppTextStyles.title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: AppTextStyles.price.copyWith(fontSize: 22),
                  ),
                ],
              ),
            ),
    );
  }
}
