import 'package:flutter/material.dart';

import '../../../../shared/widgets/placeholder_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Wishlist', icon: Icons.favorite_outline);
  }
}
