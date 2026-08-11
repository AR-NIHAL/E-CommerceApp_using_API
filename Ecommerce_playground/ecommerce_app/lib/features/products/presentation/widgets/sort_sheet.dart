import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/products_provider.dart';

class SortSheet extends StatelessWidget {
  const SortSheet({super.key, required this.selected, required this.onSelect});

  final ProductSort selected;
  final ValueChanged<ProductSort> onSelect;

  static Future<void> show(
    BuildContext context, {
    required ProductSort selected,
    required ValueChanged<ProductSort> onSelect,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SortSheet(selected: selected, onSelect: onSelect),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sort by', style: AppTextStyles.heading),
            const SizedBox(height: 16),
            _SortTile(
              option: ProductSort.featured,
              label: 'Featured',
              icon: Icons.stars_outlined,
              selected: selected == ProductSort.featured,
              onTap: () => _select(context, ProductSort.featured),
            ),
            _SortTile(
              option: ProductSort.priceLowToHigh,
              label: 'Price: Low to High',
              icon: Icons.arrow_upward,
              selected: selected == ProductSort.priceLowToHigh,
              onTap: () => _select(context, ProductSort.priceLowToHigh),
            ),
            _SortTile(
              option: ProductSort.priceHighToLow,
              label: 'Price: High to Low',
              icon: Icons.arrow_downward,
              selected: selected == ProductSort.priceHighToLow,
              onTap: () => _select(context, ProductSort.priceHighToLow),
            ),
            _SortTile(
              option: ProductSort.rating,
              label: 'Top Rated',
              icon: Icons.star_outline,
              selected: selected == ProductSort.rating,
              onTap: () => _select(context, ProductSort.rating),
            ),
          ],
        ),
      ),
    );
  }

  void _select(BuildContext context, ProductSort option) {
    onSelect(option);
    Navigator.of(context).pop();
  }
}

class _SortTile extends StatelessWidget {
  const _SortTile({
    required this.option,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final ProductSort option;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: selected ? AppColors.ink : AppColors.muted,
      ),
      title: Text(
        label,
        style: AppTextStyles.body.copyWith(
          color: selected ? AppColors.ink : AppColors.inkSoft,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: selected ? const Icon(Icons.check, color: AppColors.ink) : null,
    );
  }
}
