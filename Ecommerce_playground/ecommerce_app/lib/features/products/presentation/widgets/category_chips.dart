import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/category_provider.dart';
import '../providers/products_provider.dart';

class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesControllerProvider);
    final selected = ref.watch(productsControllerProvider).category;

    return SizedBox(
      height: 40,
      child: categories.when(
        loading: () => const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (error, stack) => const SizedBox.shrink(),
        data: (list) => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _CategoryChip(
              label: 'All',
              selected: selected == null,
              onTap: () => ref
                  .read(productsControllerProvider.notifier)
                  .selectCategory(null),
            ),
            ...list.map(
              (category) => _CategoryChip(
                label: category.name,
                selected: selected == category.slug,
                onTap: () => ref
                    .read(productsControllerProvider.notifier)
                    .selectCategory(category.slug),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? palette.ink : palette.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? palette.ink : palette.border,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.of(context).label.copyWith(
                  color: selected ? palette.onAccent : palette.inkSoft,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}
