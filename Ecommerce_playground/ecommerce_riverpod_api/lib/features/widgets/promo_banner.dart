import 'package:flutter/material.dart';
class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text('Promo Banner (Later we design it)',
              style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
