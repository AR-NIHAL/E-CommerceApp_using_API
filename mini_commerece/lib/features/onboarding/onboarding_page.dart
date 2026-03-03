import 'package:flutter/material.dart';
import 'package:mini_commerece/features/onboarding/onboarding_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16), // pixel-perfect padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Illustration placeholder (emoji in a card)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(item.emoji, style: const TextStyle(fontSize: 64)),
            ),
          ),

          const SizedBox(height: 24),

          Text(item.title, style: AppTextStyles.h1),
          const SizedBox(height: 10),
          Text(item.subtitle, style: AppTextStyles.body14),

          const Spacer(),
        ],
      ),
    );
  }
}
