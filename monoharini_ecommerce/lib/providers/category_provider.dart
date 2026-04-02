import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_provider.dart';
import '../models/category_model.dart';
import '../repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dio = ref.read(dioProvider);
  return CategoryRepository(dio);
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repository = ref.read(categoryRepositoryProvider);
  return repository.getCategories();
});
