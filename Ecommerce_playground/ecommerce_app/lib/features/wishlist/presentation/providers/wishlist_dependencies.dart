import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/storage/wishlist_storage.dart';

final wishlistStorageProvider = Provider<WishlistStorage>((ref) {
  return HiveWishlistStorage();
});
