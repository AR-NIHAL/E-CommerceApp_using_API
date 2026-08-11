import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'products_dependencies.dart';

part 'product_detail_provider.g.dart';

@Riverpod(keepAlive: true)
Future<Product> productDetail(Ref ref, int productId) {
  final usecase = GetProductUsecase(ref.watch(productsRepositoryProvider));
  return usecase.call(productId);
}
