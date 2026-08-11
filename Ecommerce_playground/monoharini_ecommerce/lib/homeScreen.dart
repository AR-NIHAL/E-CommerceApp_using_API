import 'package:flutter/material.dart';
import 'product_service.dart';

class StylishHomeScreen extends StatefulWidget {
  const StylishHomeScreen({super.key});

  @override
  State<StylishHomeScreen> createState() => _StylishHomeScreenState();
}

class _StylishHomeScreenState extends State<StylishHomeScreen> {
  final ProductService productService = ProductService();

  List<String> categories = [];
  List<dynamic> categoryProducts = [];

  bool isCategoryLoading = true;
  bool isProductLoading = false;

  String categoryError = '';
  String productError = '';

  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    setState(() {
      isCategoryLoading = true;
      categoryError = '';
    });

    try {
      final fetchedCategories = await productService.fetchCategories();

      setState(() {
        categories = fetchedCategories;
      });

      if (fetchedCategories.isNotEmpty) {
        selectedCategory = fetchedCategories.first;
        fetchProductsByCategory(selectedCategory);
      }
    } catch (e) {
      setState(() {
        categoryError = e.toString();
      });
    } finally {
      setState(() {
        isCategoryLoading = false;
      });
    }
  }

  Future<void> fetchProductsByCategory(String category) async {
    setState(() {
      isProductLoading = true;
      productError = '';
      selectedCategory = category;
    });

    try {
      final fetchedProducts = await productService.fetchProductsByCategory(
        category,
      );

      setState(() {
        categoryProducts = fetchedProducts;
      });
    } catch (e) {
      setState(() {
        productError = e.toString();
      });
    } finally {
      setState(() {
        isProductLoading = false;
      });
    }
  }

  String formatCategoryName(String name) {
    return name
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                /// Top row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.menu,
                        size: 28,
                        color: Colors.black87,
                      ),
                    ),

                    Row(
                      children: [
                        Container(
                          height: 42,
                          width: 42,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF6B81), Color(0xFF5B8DEF)],
                            ),
                          ),
                          child: const Center(
                            child: CircleAvatar(
                              radius: 11,
                              backgroundColor: Color(0xFFF5F5F5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Stylish',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4C84E8),
                            fontFamily: 'serif',
                          ),
                        ),
                      ],
                    ),

                    const CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?img=47',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                /// Search bar
                Container(
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search any Product..',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 18,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade400,
                        size: 30,
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: Icon(
                          Icons.mic_none,
                          color: Colors.grey.shade400,
                          size: 30,
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.85),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// Category section title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Featured',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        _smallActionButton(text: 'Sort', icon: Icons.swap_vert),
                        const SizedBox(width: 10),
                        _smallActionButton(
                          text: 'Filter',
                          icon: Icons.filter_list,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                /// Category list
                if (isCategoryLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (categoryError.isNotEmpty)
                  Text(categoryError, style: const TextStyle(color: Colors.red))
                else
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = selectedCategory == category;

                        return GestureDetector(
                          onTap: () {
                            fetchProductsByCategory(category);
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      'https://picsum.photos/seed/$category/200/200',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 75,
                                child: Text(
                                  formatCategoryName(category),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 24),

                /// Selected category products section
                Text(
                  selectedCategory.isEmpty
                      ? 'Products'
                      : '${formatCategoryName(selectedCategory)} Products',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 16),

                if (isProductLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (productError.isNotEmpty)
                  Text(productError, style: const TextStyle(color: Colors.red))
                else if (categoryProducts.isEmpty)
                  const Text('No products found')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categoryProducts.length,
                    itemBuilder: (context, index) {
                      final product = categoryProducts[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                product['thumbnail'],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['title'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '\$${product['price']}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _smallActionButton({required String text, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 6),
          Icon(icon, size: 18),
        ],
      ),
    );
  }
}
