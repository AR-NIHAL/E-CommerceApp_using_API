class OnboardingItem {
  final String title;
  final String subtitle;
  final String emoji; // simple, beginner-friendly placeholder for illustration

  const OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.emoji,
  });
}

class OnboardingData {
  static const List<OnboardingItem> items = [
    OnboardingItem(
      title: 'Discover Products',
      subtitle:
          'Browse thousands of items with a clean, modern shopping experience.',
      emoji: '🛍️',
    ),
    OnboardingItem(
      title: 'Fast Delivery',
      subtitle: 'Get your order delivered quickly with real-time updates.',
      emoji: '🚚',
    ),
    OnboardingItem(
      title: 'Secure Payment',
      subtitle: 'Pay safely with trusted payment methods and checkout.',
      emoji: '🔒',
    ),
  ];
}
