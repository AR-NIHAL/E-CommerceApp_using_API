import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_commerece/core/network/product_api.dart';
import 'package:mini_commerece/features/model/product_model.dart';

// API instance provider
final productApiProvider = Provider<ProductApi>((ref) {
  return ProductApi();
});

// Product list provider (AsyncValue: loading/error/data)
final productListProvider = FutureProvider<List<Product>>((ref) async {
  final api = ref.read(productApiProvider);
  return api.fetchProducts();
});
