import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/storage/order_storage.dart';

final orderStorageProvider = Provider<OrderStorage>((ref) {
  return HiveOrderStorage();
});