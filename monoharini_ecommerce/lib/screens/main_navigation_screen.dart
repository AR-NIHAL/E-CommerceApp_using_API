import 'package:flutter/material.dart';
import 'package:monoharini_ecommerce/screens/favourite_screen.dart';
import 'package:monoharini_ecommerce/screens/cart_screen.dart';
import 'package:monoharini_ecommerce/screens/homescreen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    FavoritesScreen(),
    CartScreen(),
    SearchPlaceholderScreen(),
    SettingsPlaceholderScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            height: 62,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_outlined,
                    label: 'Home',
                    isSelected: currentIndex == 0,
                    onTap: () => onTabTapped(0),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.favorite_border,
                    activeIcon: Icons.favorite_border,
                    label: 'Wishlist',
                    isSelected: currentIndex == 1,
                    onTap: () => onTabTapped(1),
                  ),
                ),
                Expanded(
                  child: _CenterCartButton(
                    isSelected: currentIndex == 2,
                    onTap: () => onTabTapped(2),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.search,
                    activeIcon: Icons.search,
                    label: 'Search',
                    isSelected: currentIndex == 3,
                    onTap: () => onTabTapped(3),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_outlined,
                    label: 'Setting',
                    isSelected: currentIndex == 4,
                    onTap: () => onTabTapped(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFFFF5A52);
    const Color inactiveColor = Color(0xFF222222);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            size: 24,
            color: isSelected ? activeColor : inactiveColor,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterCartButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _CenterCartButton({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFFFF5A52);
    const Color inactiveColor = Color(0xFF222222);

    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFFF1F1F1), width: 1),
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 24,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchPlaceholderScreen extends StatelessWidget {
  const SearchPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      body: Center(
        child: Text(
          'Search Screen',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class SettingsPlaceholderScreen extends StatelessWidget {
  const SettingsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      body: Center(
        child: Text(
          'Settings Screen',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
