import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../widgets/product_item.dart';
import '../widgets/search_textfield.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final bool showBackButton;

  const SearchScreen({super.key, this.showBackButton = true});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final productsAsync = ref.watch(filteredProductsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            children: [
              Row(
                children: [
                  if (widget.showBackButton) ...[
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: SearchTextField(
                      controller: _searchController,
                      hintText: 'Search products...',
                      autofocus: true,
                      onChanged: (value) {
                        ref.read(searchQueryProvider.notifier).state = value;
                      },
                      onMicTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: query.trim().isEmpty
                    ? const Center(
                        child: Text(
                          'Type product name to search',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : productsAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stackTrace) => Center(
                          child: Text(
                            'Error: $error',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        data: (products) {
                          if (products.isEmpty) {
                            return const Center(
                              child: Text(
                                'No products found',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            );
                          }

                          return GridView.builder(
                            itemCount: products.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 0.68,
                                ),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return ProductItem(product: product);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
