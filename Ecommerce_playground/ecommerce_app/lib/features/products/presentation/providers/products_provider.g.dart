// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProductsController)
const productsControllerProvider = ProductsControllerProvider._();

final class ProductsControllerProvider
    extends $NotifierProvider<ProductsController, ProductsState> {
  const ProductsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productsControllerHash();

  @$internal
  @override
  ProductsController create() => ProductsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductsState>(value),
    );
  }
}

String _$productsControllerHash() =>
    r'3bf22666799d618eb07016470d8093b54d610d34';

abstract class _$ProductsController extends $Notifier<ProductsState> {
  ProductsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ProductsState, ProductsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProductsState, ProductsState>,
              ProductsState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
