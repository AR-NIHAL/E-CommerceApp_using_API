import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/category.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'products_dependencies.dart';

part 'category_provider.g.dart';

@Riverpod(keepAlive: true)
class CategoriesController extends _$CategoriesController {
  @override
  Future<List<Category>> build() {
    final usecase = GetCategoriesUsecase(ref.read(productsRepositoryProvider));
    return usecase();
  }
}
