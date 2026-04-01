import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_commerece/core/network/product_details_api.dart';
import 'package:mini_commerece/features/model/product_details_model.dart';

final productDetailsApiProvider = Provider<ProductDetailsApi>((ref) {
  return ProductDetailsApi();
});

final productDetailsProvider = FutureProvider.family<ProductDetails, int>((
  ref,
  id,
) async {
  final api = ref.read(productDetailsApiProvider);
  return api.fetchDetails(id);
});
