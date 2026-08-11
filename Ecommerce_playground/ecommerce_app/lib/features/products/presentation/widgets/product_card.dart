import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.isWishlisted = false,
    this.onToggleWishlist,
  });

  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool isWishlisted;
  final VoidCallback? onToggleWishlist;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (product.thumbnail.isNotEmpty)
                    Image.network(
                      product.thumbnail,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: AppColors.border,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_outlined,
                            size: 32,
                            color: AppColors.muted,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stack) => Container(
                        color: AppColors.border,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_outlined,
                          size: 32,
                          color: AppColors.muted,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: AppColors.border,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_outlined,
                        size: 32,
                        color: AppColors.muted,
                      ),
                    ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _DiscountBadge(
                      hasDiscount: product.hasDiscount,
                      discount: product.discountPercentage,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _WishlistButton(
                      isWishlisted: isWishlisted,
                      onPressed: onToggleWishlist,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: product.hasDiscount
                            ? Row(
                                children: [
                                  Text(
                                    '\$${product.discountPrice.toStringAsFixed(2)}',
                                    style: AppTextStyles.price.copyWith(
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: AppTextStyles.label.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: AppTextStyles.price.copyWith(fontSize: 15),
                              ),
                      ),
                      _AddToCartButton(onPressed: onAddToCart),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _RatingRow(rating: product.rating),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.hasDiscount, required this.discount});

  final bool hasDiscount;
  final double discount;

  @override
  Widget build(BuildContext context) {
    if (!hasDiscount) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '-${discount.round()}%',
        style: AppTextStyles.label.copyWith(
          color: AppColors.onAccent,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _WishlistButton extends StatelessWidget {
  const _WishlistButton({required this.isWishlisted, this.onPressed});

  final bool isWishlisted;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            isWishlisted ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color: isWishlisted ? AppColors.error : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.add, size: 18, color: AppColors.onAccent),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, size: 16, color: AppColors.rating),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: AppTextStyles.label.copyWith(color: AppColors.inkSoft),
        ),
      ],
    );
  }
}
