import 'package:flutter/material.dart';

import '../../../../shared/widgets/placeholder_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Home', icon: Icons.storefront_outlined);
  }
}
