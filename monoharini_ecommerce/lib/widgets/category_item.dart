import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;
  final bool isSelected;

  const CategoryItem({
    super.key,
    required this.category,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkResponse(
              onTap: onTap,
              containedInkWell: true,
              highlightShape: BoxShape.circle,
              customBorder: const CircleBorder(),
              radius: 40,
              child: Ink(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color(0xFFE8F3FF)
                      : const Color(0xFFEFEFEF),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4A67E8)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(category.imagePath, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 72,
            child: Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF4A67E8)
                    : const Color(0xFF4B3168),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
