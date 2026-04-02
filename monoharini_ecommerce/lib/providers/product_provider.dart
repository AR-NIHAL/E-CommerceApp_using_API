import 'package:flutter_riverpod/flutter_riverpod.dart';
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
