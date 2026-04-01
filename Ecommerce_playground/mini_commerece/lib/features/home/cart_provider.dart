import 'package:flutter_riverpod/legacy.dart';
import 'package:mini_commerece/features/model/cart_item.dart';
import 'package:mini_commerece/features/model/product_model.dart';

class CartState {
  final List<CartItem> items;

  const CartState({required this.items});

  int get totalItems => items.fold<int>(0, (sum, e) => sum + e.quantity);

  double get totalPrice => items.fold<double>(0, (sum, e) => sum + e.lineTotal);

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }

  factory CartState.empty() => const CartState(items: []);
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState.empty());

  void add(Product product) {
    final index = state.items.indexWhere((e) => e.product.id == product.id);

    if (index == -1) {
      // new item
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(product: product, quantity: 1),
        ],
      );
    } else {
      // increase qty
      final updated = [...state.items];
      final current = updated[index];
      updated[index] = current.copyWith(quantity: current.quantity + 1);
      state = state.copyWith(items: updated);
    }
  }

  void increase(int productId) {
    final index = state.items.indexWhere((e) => e.product.id == productId);
    if (index == -1) return;

    final updated = [...state.items];
    final current = updated[index];
    updated[index] = current.copyWith(quantity: current.quantity + 1);
    state = state.copyWith(items: updated);
  }

  void decrease(int productId) {
    final index = state.items.indexWhere((e) => e.product.id == productId);
    if (index == -1) return;

    final updated = [...state.items];
    final current = updated[index];

    if (current.quantity <= 1) {
      // remove when qty goes to 0
      updated.removeAt(index);
    } else {
      updated[index] = current.copyWith(quantity: current.quantity - 1);
    }

    state = state.copyWith(items: updated);
  }

  void remove(int productId) {
    state = state.copyWith(
      items: state.items.where((e) => e.product.id != productId).toList(),
    );
  }

  void clear() {
    state = CartState.empty();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);
