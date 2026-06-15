import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../core/network/dio_provider.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final dio = ref.read(dioProvider);
  return ProductRepository(dio);
});

final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  return repository.getProducts();
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final homeFilteredProductsProvider = Provider<AsyncValue<List<ProductModel>>>((
  ref,
) {
  final productsAsync = ref.watch(productsProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return productsAsync.whenData((products) {
    if (selectedCategory == null || selectedCategory.isEmpty) {
      return products;
    }

    return products.where((product) {
      return product.category.toLowerCase() == selectedCategory.toLowerCase();
    }).toList();
  });
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredProductsProvider = Provider<AsyncValue<List<ProductModel>>>((
  ref,
) {
  final productsAsync = ref.watch(productsProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  return productsAsync.whenData((products) {
    if (query.isEmpty) {
      return [];
    }

    return products.where((product) {
      final title = product.title.toLowerCase();
      final description = product.description.toLowerCase();
      final category = product.category.toLowerCase();

      return title.contains(query) ||
          description.contains(query) ||
          category.contains(query);
    }).toList();
  });
});
