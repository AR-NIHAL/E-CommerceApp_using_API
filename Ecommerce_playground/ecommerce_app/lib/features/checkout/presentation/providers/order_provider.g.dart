// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OrderController)
const orderControllerProvider = OrderControllerProvider._();

final class OrderControllerProvider
    extends $NotifierProvider<OrderController, List<Order>> {
  const OrderControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderControllerHash();

  @$internal
  @override
  OrderController create() => OrderController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Order> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Order>>(value),
    );
  }
}

String _$orderControllerHash() => r'c5d682335ada9912d5af2fda1266f1084c15ed1d';

abstract class _$OrderController extends $Notifier<List<Order>> {
  List<Order> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<Order>, List<Order>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Order>, List<Order>>,
              List<Order>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
