import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import 'product_item.dart';

class ProductSection extends ConsumerWidget {
  const ProductSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(homeFilteredProductsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return productsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
      ),
      data: (products) {
        if (products.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            alignment: Alignment.center,
            child: Text(
              selectedCategory == null
                  ? 'No products found'
                  : 'No products found in this category',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          );
        }

        return GridView.builder(
          itemCount: products.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductItem(product: product);
          },
        );
      },
    );
  }
}
