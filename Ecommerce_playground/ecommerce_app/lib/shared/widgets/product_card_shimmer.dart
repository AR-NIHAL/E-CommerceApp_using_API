import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app/theme/app_colors.dart';

class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
