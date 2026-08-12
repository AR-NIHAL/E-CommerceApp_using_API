import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../products/domain/entities/product.dart';
import '../../data/storage/wishlist_storage.dart';
import 'wishlist_dependencies.dart';

part 'wishlist_provider.g.dart';

@Riverpod(keepAlive: true)
class WishlistController extends _$WishlistController {
  WishlistStorage get _storage => ref.read(wishlistStorageProvider);

  @override
  List<Product> build() {
    return _storage.readProducts();
  }

  bool isWishlisted(int productId) {
    return state.any((product) => product.id == productId);
  }

  void toggle(Product product) {
    if (isWishlisted(product.id)) {
      remove(product.id);
    } else {
      _setState([...state, product]);
    }
  }

  void remove(int productId) {
    _setState(
      state.where((product) => product.id != productId).toList(),
    );
  }

  void clear() {
    _setState(const []);
  }

  void _setState(List<Product> next) {
    state = next;
    _storage.saveProducts(next);
  }
}
