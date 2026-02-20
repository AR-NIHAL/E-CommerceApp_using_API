import 'package:ecommerce_riverpod_api/features/widgets/category_list.dart';
import 'package:ecommerce_riverpod_api/features/widgets/flash_sale.dart';
import 'package:ecommerce_riverpod_api/features/widgets/promo_banner.dart';
import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/section_title.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: const Drawer(child: Center(child: Text('Drawer content'))),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HomeHeader(),
            const SizedBox(height: 12),

            SectionTitle(title: '#SpecialForYou', onSeeAll: () {}),
            const SizedBox(height: 8),
            const PromoBanner(),

            const SizedBox(height: 16),
            SectionTitle(title: 'Categories', onSeeAll: () {}),
            const SizedBox(height: 8),
            const CategoryList(),

            const SizedBox(height: 16),
            SectionTitle(title: 'Flash Sale', onSeeAll: () {}),
            const SizedBox(height: 8),
            const FlashSaleGrid(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
