import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'products_dependencies.dart';

part 'products_provider.g.dart';

enum ProductSort { featured, priceLowToHigh, priceHighToLow, rating }

typedef _PageResult = ({List<Product> products, bool hasMore, String? error});

class ProductsState {
  const ProductsState({
    this.products = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.category,
    this.query,
    this.sort = ProductSort.featured,
  });

  final List<Product> products;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final String? category;
  final String? query;
  final ProductSort sort;

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
    String? category,
    bool clearCategory = false,
    String? query,
    bool clearQuery = false,
    ProductSort? sort,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : error ?? this.error,
      category: clearCategory ? null : category ?? this.category,
      query: clearQuery ? null : query ?? this.query,
      sort: sort ?? this.sort,
    );
  }
}

@Riverpod(keepAlive: true)
class ProductsController extends _$ProductsController {
  static const int _pageSize = 20;

  @override
  ProductsState build() {
    _loadInitial();
    return const ProductsState();
  }

  Future<void> _loadInitial() async {
    final result = await _fetchPage(category: null, query: null, skip: 0);
    _applyFirstPage(result);
  }

  Future<void> refresh() async {
    final current = state;
    state = current.copyWith(isLoading: true, clearError: true);
    final result = await _fetchPage(
      category: current.category,
      query: current.query,
      skip: 0,
    );
    _applyFirstPage(result);
  }

  Future<void> loadMore() async {
    final current = state;
    if (current.isLoading ||
        current.isLoadingMore ||
        !current.hasMore ||
        current.error != null) {
      return;
    }

    state = current.copyWith(isLoadingMore: true);
    final result = await _fetchPage(
      category: current.category,
      query: current.query,
      skip: current.products.length,
    );

    if (result.error != null) {
      state = state.copyWith(isLoadingMore: false, error: result.error);
      return;
    }

    state = state.copyWith(
      products: [...state.products, ...result.products],
      isLoadingMore: false,
      hasMore: result.hasMore,
      clearError: true,
    );
  }

  Future<void> selectCategory(String? category) async {
    state = state.copyWith(
      category: category,
      clearCategory: category == null,
      isLoading: true,
      products: const [],
      hasMore: true,
      clearError: true,
    );
    final result = await _fetchPage(category: category, query: state.query, skip: 0);
    _applyFirstPage(result);
  }

  Future<void> search(String query) async {
    final normalized = query.trim();
    if (normalized == state.query) return;

    state = state.copyWith(
      query: normalized.isEmpty ? null : normalized,
      clearQuery: normalized.isEmpty,
      isLoading: true,
      products: const [],
      hasMore: true,
      clearError: true,
    );
    final result = await _fetchPage(
      category: state.category,
      query: normalized.isEmpty ? null : normalized,
      skip: 0,
    );
    _applyFirstPage(result);
  }

  void setSort(ProductSort sort) {
    final sorted = [...state.products];
    switch (sort) {
      case ProductSort.featured:
        sorted.sort((a, b) => a.id.compareTo(b.id));
      case ProductSort.priceLowToHigh:
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceHighToLow:
        sorted.sort((a, b) => b.price.compareTo(a.price));
      case ProductSort.rating:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
    }
    state = state.copyWith(products: sorted, sort: sort);
  }

  void clearFilters() {
    state = state.copyWith(
      clearCategory: true,
      clearQuery: true,
      sort: ProductSort.featured,
      isLoading: true,
      products: const [],
      hasMore: true,
      clearError: true,
    );
    _loadInitial();
  }

  void _applyFirstPage(_PageResult result) {
    if (result.error != null) {
      state = state.copyWith(isLoading: false, error: result.error);
      return;
    }

    state = state.copyWith(
      products: result.products,
      isLoading: false,
      hasMore: result.hasMore,
      clearError: true,
    );
  }

  Future<_PageResult> _fetchPage({
    required String? category,
    required String? query,
    required int skip,
  }) async {
    final usecase = GetProductsUsecase(ref.read(productsRepositoryProvider));
    try {
      final page = await usecase.call(
        GetProductsParams(
          limit: _pageSize,
          skip: skip,
          category: category,
          query: query,
        ),
      );
      return (products: page.products, hasMore: page.hasMore, error: null);
    } catch (error) {
      return (
        products: <Product>[],
        hasMore: false,
        error: error.toString(),
      );
    }
  }
}
