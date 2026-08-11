import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../products/domain/entities/product.dart';
import '../../data/storage/cart_storage.dart';
import '../../domain/entities/cart_item.dart';
import 'cart_dependencies.dart';

part 'cart_provider.g.dart';

class CartState {
  const CartState({this.items = const []});

  final List<CartItem> items;

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      items.fold(0, (sum, item) => sum + item.lineTotal);

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}

@Riverpod(keepAlive: true)
class CartController extends _$CartController {
  CartStorage get _storage => ref.read(cartStorageProvider);

  @override
  CartState build() {
    return CartState(items: _storage.readItems());
  }

  void addProduct(Product product, {int quantity = 1}) {
    final existingIndex =
        state.items.indexWhere((item) => item.product.id == product.id);

    final updated = [...state.items];
    if (existingIndex >= 0) {
      final item = updated[existingIndex];
      updated[existingIndex] =
          item.copyWith(quantity: item.quantity + quantity);
    } else {
      updated.add(CartItem(product: product, quantity: quantity));
    }
    _setState(CartState(items: updated));
  }

  void increment(int productId) {
    _updateQuantity(productId, 1);
  }

  void decrement(int productId) {
    _updateQuantity(productId, -1);
  }

  void removeItem(int productId) {
    _setState(
      CartState(
        items: state.items
            .where((item) => item.product.id != productId)
            .toList(),
      ),
    );
  }

  void clear() {
    _setState(const CartState());
  }

  void _updateQuantity(int productId, int delta) {
    final updated = [...state.items];
    final index = updated.indexWhere((item) => item.product.id == productId);
    if (index < 0) return;

    final item = updated[index];
    final newQuantity = item.quantity + delta;

    if (newQuantity <= 0) {
      updated.removeAt(index);
    } else {
      updated[index] = item.copyWith(quantity: newQuantity);
    }

    _setState(CartState(items: updated));
  }

  void _setState(CartState next) {
    state = next;
    _storage.saveItems(next.items);
  }
}
