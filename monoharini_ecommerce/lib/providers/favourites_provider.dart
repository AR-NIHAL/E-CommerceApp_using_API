import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class FavoritesNotifier extends StateNotifier<List<int>> {
  FavoritesNotifier() : super([]);

  void toggleFavorite(int productId) {
    if (state.contains(productId)) {
      state = state.where((id) => id != productId).toList();
    } else {
      state = [...state, productId];
    }
  }

  bool isFavorite(int productId) {
    return state.contains(productId);
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<int>>((
  ref,
) {
  return FavoritesNotifier();
});

final favoritesCountProvider = Provider<int>((ref) {
  final favoriteIds = ref.watch(favoritesProvider);
  return favoriteIds.length;
});
