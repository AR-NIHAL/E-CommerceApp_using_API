import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app/app/theme/app_colors.dart';

void main() {
  test('design tokens expose the neutral palette', () {
    expect(AppColors.background, const Color(0xFFFAFAF8));
    expect(AppColors.ink, const Color(0xFF141414));
    expect(AppColors.accent, AppColors.ink);
  });
}
