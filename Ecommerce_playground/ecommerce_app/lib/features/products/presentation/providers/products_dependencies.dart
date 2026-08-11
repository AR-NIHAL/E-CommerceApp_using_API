import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/products_remote_source.dart';
import '../../data/repositories/products_repository_impl.dart';
import '../../domain/repositories/products_repository.dart';

final productsRemoteSourceProvider = Provider<ProductsRemoteDataSource>((ref) {
  return ProductsRemoteDataSource(ref.watch(dioProvider));
});

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepositoryImpl(
    remoteSource: ref.watch(productsRemoteSourceProvider),
  );
});
