import 'package:flutter/material.dart';
import '../widgets/category_section.dart';
import '../widgets/home_header.dart';
import '../widgets/product_section.dart';
import '../widgets/search_textfield.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                  onChanged: (value) {},
                  onMicTap: () {},
                ),
                const SizedBox(height: 22),
                const CategorySection(),
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
