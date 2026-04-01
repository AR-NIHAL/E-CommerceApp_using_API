import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/product.dart';

// 1) dio
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: 'https://fakestoreapi.com'));
});

// 2) products from API
final productListProvider = FutureProvider<List<Product>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/products');
  final list = (res.data as List).cast<Map<String, dynamic>>();
  return list.map(Product.fromJson).toList();
});

// 3) search query (From Phase-1)
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productListProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  return productsAsync.whenData((products) {
    if (query.isEmpty) return products;

    return products.where((p) {
      return p.title.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);
    }).toList();
  });
});
