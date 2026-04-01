import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../core/dio_client.dart';
import '../data/product_api.dart';
import '../data/product_models.dart';

final dioProvider = Provider<Dio>((ref) {
  return createDioClient();
});

final productApiProvider = Provider<ProductApi>((ref) {
  return ProductApi(ref.watch(dioProvider));
});

final productsProvider = FutureProvider<ProductsResponse>((ref) async {
  final api = ref.watch(productApiProvider);
  return api.fetchProducts(limit: 20, skip: 0);
});