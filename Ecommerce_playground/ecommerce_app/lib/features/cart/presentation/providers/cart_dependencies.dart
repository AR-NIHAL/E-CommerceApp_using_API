import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/storage/cart_storage.dart';

final cartStorageProvider = Provider<CartStorage>((ref) {
  return HiveCartStorage();
});
