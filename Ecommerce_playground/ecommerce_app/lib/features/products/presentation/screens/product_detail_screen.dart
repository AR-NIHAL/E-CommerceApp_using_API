import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/entities/product.dart';
import '../providers/product_detail_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final int productId;

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final PageController _galleryController = PageController();
  int _currentImage = 0;
  bool _isWishlisted = false;

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  void _onAddToCart(Product product) {
    ref.read(cartControllerProvider.notifier).addProduct(product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Added to cart'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View cart',
          onPressed: () => context.go(AppRoutes.cart),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(productDetailProvider(widget.productId)),
        ),
        data: (product) => _ProductDetailBody(
          product: product,
          galleryController: _galleryController,
          currentImage: _currentImage,
          isWishlisted: _isWishlisted,
          onImageChanged: (index) => setState(() => _currentImage = index),
          onToggleWishlist: () => setState(() => _isWishlisted = !_isWishlisted),
          onAddToCart: () => _onAddToCart(product),
        ),
      ),
    );
  }
}

class _ProductDetailBody extends StatelessWidget {
  const _ProductDetailBody({
    required this.product,
    required this.galleryController,
    required this.currentImage,
    required this.isWishlisted,
    required this.onImageChanged,
    required this.onToggleWishlist,
    required this.onAddToCart,
  });

  final Product product;
  final PageController galleryController;
  final int currentImage;
  final bool isWishlisted;
  final ValueChanged<int> onImageChanged;
  final VoidCallback onToggleWishlist;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ImageGallery(
                  productId: product.id,
                  images: product.images,
                  thumbnail: product.thumbnail,
                  controller: galleryController,
                  currentIndex: currentImage,
                  onPageChanged: onImageChanged,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BrandRow(
                        brand: product.brand,
                        category: product.category,
                        isWishlisted: isWishlisted,
                        onToggleWishlist: onToggleWishlist,
                      ),
                      const SizedBox(height: 12),
                      Text(product.title, style: AppTextStyles.title),
                      const SizedBox(height: 16),
                      _PriceRow(product: product),
                      const SizedBox(height: 16),
                      _MetaRow(product: product),
                      const SizedBox(height: 24),
                      const Text('Description', style: AppTextStyles.heading),
                      const SizedBox(height: 8),
                      Text(product.description, style: AppTextStyles.body),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _AddToCartBar(product: product, onPressed: onAddToCart),
      ],
    );
  }
}

class _ImageGallery extends StatelessWidget {
  const _ImageGallery({
    required this.productId,
    required this.images,
    required this.thumbnail,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final int productId;
  final List<String> images;
  final String thumbnail;
  final PageController controller;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final galleryImages = images.isEmpty && thumbnail.isNotEmpty
        ? [thumbnail]
        : images;

    return SizedBox(
      height: 360,
      child: Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemCount: galleryImages.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              return Hero(
                tag: 'product-image-$productId',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      galleryImages[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: AppColors.border,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stack) => Container(
                        color: AppColors.border,
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (galleryImages.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  galleryImages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: index == currentIndex ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: index == currentIndex
                          ? AppColors.ink
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow({
    required this.brand,
    required this.category,
    required this.isWishlisted,
    required this.onToggleWishlist,
  });

  final String brand;
  final String category;
  final bool isWishlisted;
  final VoidCallback onToggleWishlist;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            [if (brand.isNotEmpty) brand, if (category.isNotEmpty) category]
                .join(' · '),
            style: AppTextStyles.label,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: onToggleWishlist,
          icon: Icon(
            isWishlisted ? Icons.favorite : Icons.favorite_border,
            color: isWishlisted ? AppColors.error : AppColors.ink,
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '\$${product.discountPrice.toStringAsFixed(2)}',
          style: AppTextStyles.display.copyWith(fontSize: 28),
        ),
        if (product.hasDiscount) ...[
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: AppTextStyles.label.copyWith(
                decoration: TextDecoration.lineThrough,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '-${product.discountPercentage.round()}%',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.onAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final inStock = product.stock > 0;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: AppColors.rating),
              const SizedBox(width: 4),
              Text(
                product.rating.toStringAsFixed(1),
                style: AppTextStyles.label.copyWith(color: AppColors.ink),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                inStock ? Icons.check_circle_outline : Icons.error_outline,
                size: 16,
                color: inStock ? AppColors.rating : AppColors.error,
              ),
              const SizedBox(width: 4),
              Text(
                inStock ? 'In stock' : 'Out of stock',
                style: AppTextStyles.label.copyWith(
                  color: inStock ? AppColors.rating : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({required this.product, required this.onPressed});

  final Product product;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total', style: AppTextStyles.label),
                Text(
                  '\$${(product.discountPrice).toStringAsFixed(2)}',
                  style: AppTextStyles.heading.copyWith(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: onPressed,
                child: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
