import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monoharini_ecommerce/screens/search_screen.dart';
import 'package:monoharini_ecommerce/widgets/deal_of_the_day_card.dart';
import 'package:monoharini_ecommerce/widgets/promo_banner_section.dart';
import '../providers/product_provider.dart';
import '../widgets/category_section.dart';
import '../widgets/home_header.dart';
import '../widgets/product_section.dart';
import '../widgets/search_textfield.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeader(),
                const SizedBox(height: 18),
                SearchTextField(
                  controller: searchController,
                  hintText: 'Search any Product..',
                  readOnly: true,
                  onTap: () {
                    ref.read(searchQueryProvider.notifier).state = '';
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                  onMicTap: () {},
                ),
                const SizedBox(height: 22),
                const CategorySection(),
                const SizedBox(height: 18),
                const PromoBannerSection(),
                const SizedBox(height: 14),
                const DealOfDayCard(),
                const SizedBox(height: 24),
                const ProductSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
