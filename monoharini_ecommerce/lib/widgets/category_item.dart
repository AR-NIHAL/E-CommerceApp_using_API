import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;

  const CategoryItem({super.key, required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.only(right: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEFEFEF),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(category.imagePath, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 72,
              child: Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4B3168),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
