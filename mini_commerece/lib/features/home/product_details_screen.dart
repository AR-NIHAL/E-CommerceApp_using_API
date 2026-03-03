import 'package:flutter/material.dart';
import 'package:mini_commerece/features/model/product_model.dart';
import '../../../core/theme/app_text_styles.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.title, style: AppTextStyles.h1),
            const SizedBox(height: 8),
            Text('Details UI coming in Module 4', style: AppTextStyles.body14),
          ],
        ),
      ),
    );
  }
}
