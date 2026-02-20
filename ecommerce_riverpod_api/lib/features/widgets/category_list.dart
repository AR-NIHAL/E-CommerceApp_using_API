import 'package:flutter/material.dart';
class CategoryList extends StatelessWidget {
  const CategoryList();

  @override
  Widget build(BuildContext context) {
    final items = ['Cloth', 'Gym', 'Fashion', 'Medicine', 'Watch'];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          return Column(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.category),
              ),
              const SizedBox(height: 6),
              Text(items[i], style: const TextStyle(fontSize: 12)),
            ],
          );
        },
      ),
    );
  }
}
