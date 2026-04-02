import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import 'category_item.dart';
import 'small_action_button.dart';

class CategorySection extends ConsumerWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'All Featured',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            SmallActionButton(
              text: 'Sort',
              icon: Icons.swap_vert,
              onTap: () {
                debugPrint('Sort tapped');
              },
            ),
            const SizedBox(width: 10),
            SmallActionButton(
              text: 'Filter',
              icon: Icons.filter_alt_outlined,
              onTap: () {
                debugPrint('Filter tapped');
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        categoriesAsync.when(
          loading: () => const SizedBox(
            height: 105,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => SizedBox(
            height: 105,
            child: Center(
              child: Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ),
          ),
          data: (categories) {
            if (categories.isEmpty) {
              return const SizedBox(
                height: 105,
                child: Center(
                  child: Text(
                    'No categories found',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 105,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];

                  return CategoryItem(
                    category: category,
                    onTap: () {
                      debugPrint('Clicked category: ${category.slug}');
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
