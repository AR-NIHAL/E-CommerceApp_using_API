import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]);

  void addToCart(ProductModel product) {
    final existingIndex = state.indexWhere((item) => item.id == product.id);

    if (existingIndex != -1) {
      final updatedList = [...state];
      final existingItem = updatedList[existingIndex];

      updatedList[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      );

      state = updatedList;
    } else {
      state = [
        ...state,
        CartItemModel(
          id: product.id,
          title: product.title,
          price: product.price,
          thumbnail: product.thumbnail,
          quantity: 1,
        ),
      ];
    }
  }

  void removeFromCart(int productId) {
    state = state.where((item) => item.id != productId).toList();
  }

  void increaseQuantity(int productId) {
    state = state.map((item) {
      if (item.id == productId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();
  }

  void decreaseQuantity(int productId) {
    state = state
        .map((item) {
          if (item.id == productId) {
            return item.copyWith(quantity: item.quantity - 1);
          }
          return item;
        })
        .where((item) => item.quantity > 0)
        .toList();
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemModel>>((
  ref,
) {
  return CartNotifier();
});

final cartItemCountProvider = Provider<int>((ref) {
  final cartItems = ref.watch(cartProvider);

  int total = 0;
  for (final item in cartItems) {
    total += item.quantity;
  }
  return total;
});

final cartTotalPriceProvider = Provider<double>((ref) {
  final cartItems = ref.watch(cartProvider);

  double total = 0;
  for (final item in cartItems) {
    total += item.price * item.quantity;
  }
  return total;
});
