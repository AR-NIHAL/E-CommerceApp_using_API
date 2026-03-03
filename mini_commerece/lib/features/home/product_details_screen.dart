import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_commerece/features/home/product_details_provider.dart';
import 'package:mini_commerece/features/model/product_model.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final Product product; // passed from home as quick preview

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(productDetailsProvider(product.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Product')),
      body: detailsAsync.when(
        loading: () => const _DetailsLoading(),
        error: (e, _) => _DetailsError(
          message: 'Failed to load details.\n$e',
          onRetry: () => ref.refresh(productDetailsProvider(product.id)),
        ),
        data: (details) {
          final heroUrl = details.images.isNotEmpty
              ? details.images.first
              : details.thumbnail;

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                children: [
                  // Main image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 1.15,
                      child: Image.network(
                        heroUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.border,
                          child: const Center(child: Icon(Icons.broken_image)),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(details.title, style: AppTextStyles.h1),

                  const SizedBox(height: 10),

                  // Price + Rating
                  Row(
                    children: [
                      Text(
                        '\$${details.price.toStringAsFixed(0)}',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              details.rating.toStringAsFixed(1),
                              style: AppTextStyles.caption12.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Description',
                    style: AppTextStyles.body16.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(details.description, style: AppTextStyles.body14),

                  const SizedBox(height: 18),

                  // Small gallery (optional, nice touch)
                  if (details.images.length > 1) ...[
                    Text(
                      'Gallery',
                      style: AppTextStyles.body16.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 78,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: details.images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final url = details.images[i];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.border,
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 18),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),

              // Sticky bottom bar (Add to Cart)
              _BottomBar(
                price: details.price,
                onAddToCart: () {
                  // Module 5 এ real cart provider বসবে
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to cart (coming in Module 5)'),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final double price;
  final VoidCallback onAddToCart;

  const _BottomBar({required this.price, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            // Price quick view
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price', style: AppTextStyles.caption12),
                  const SizedBox(height: 2),
                  Text(
                    '\$${price.toStringAsFixed(0)}',
                    style: AppTextStyles.body16.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            SizedBox(
              height: 52, // requirement
              width: 170,
              child: ElevatedButton(
                onPressed: onAddToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsLoading extends StatelessWidget {
  const _DetailsLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _DetailsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DetailsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: AppTextStyles.body14,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
