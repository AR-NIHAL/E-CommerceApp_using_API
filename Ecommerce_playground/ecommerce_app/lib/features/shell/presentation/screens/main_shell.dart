import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../wishlist/presentation/providers/wishlist_provider.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartControllerProvider).totalItems;
    final wishlistItems = ref.watch(wishlistControllerProvider).length;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: navigationShell.currentIndex,
        cartCount: cartItems,
        wishlistCount: wishlistItems,
        onTap: (index) => _onDestinationSelected(context, index),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.currentIndex,
    required this.cartCount,
    required this.wishlistCount,
    required this.onTap,
  });

  final int currentIndex;
  final int cartCount;
  final int wishlistCount;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              selected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.favorite_outline,
              selectedIcon: Icons.favorite,
              selected: currentIndex == 1,
              badgeCount: wishlistCount,
              onTap: () => onTap(1),
            ),
            _NavItem(
              icon: Icons.shopping_bag_outlined,
              selectedIcon: Icons.shopping_bag,
              selected: currentIndex == 2,
              badgeCount: cartCount,
              onTap: () => onTap(2),
            ),
            _NavItem(
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings,
              selected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final color = selected ? palette.ink : palette.muted;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Badge(
              isLabelVisible: badgeCount > 0,
              label: Text('$badgeCount'),
              child: Icon(
                selected ? selectedIcon : icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: selected ? 5 : 3,
              height: selected ? 5 : 3,
              decoration: BoxDecoration(
                color: selected ? palette.ink : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}