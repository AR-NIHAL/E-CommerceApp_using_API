import 'package:flutter/material.dart';

class OnboardingItem {
  const OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

const List<OnboardingItem> onboardingItems = [
  OnboardingItem(
    title: 'Discover your style',
    subtitle: 'Browse a curated catalog of products crafted for modern living.',
    icon: Icons.storefront_outlined,
  ),
  OnboardingItem(
    title: 'Fast, effortless delivery',
    subtitle: 'Track every order and get it delivered right to your door.',
    icon: Icons.local_shipping_outlined,
  ),
  OnboardingItem(
    title: 'Secure payments',
    subtitle: 'Check out with confidence thanks to secure, protected payments.',
    icon: Icons.verified_user_outlined,
  ),
];
