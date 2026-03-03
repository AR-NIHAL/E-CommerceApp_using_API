import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Center(child: Text('Cart Coming Soon', style: AppTextStyles.h1)),
    );
  }
}
