import 'package:flutter/material.dart';

import '../../../../shared/widgets/placeholder_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Cart', icon: Icons.shopping_bag_outlined);
  }
}
