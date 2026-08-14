import 'package:hive/hive.dart';

import '../../../../core/storage/hive_boxes.dart';
import '../../domain/entities/order.dart';

abstract class OrderStorage {
  List<Order> readOrders();

  void saveOrders(List<Order> orders);

  void clear();
}

class HiveOrderStorage implements OrderStorage {
  static const String _ordersKey = 'items';

  @override
  List<Order> readOrders() {
    final stored = Hive.box(HiveBoxes.orders).get(_ordersKey);
    if (stored == null) return const [];
    return (stored as List).cast<Order>();
  }

  @override
  void saveOrders(List<Order> orders) {
    Hive.box(HiveBoxes.orders).put(_ordersKey, orders);
  }

  @override
  void clear() {
    Hive.box(HiveBoxes.orders).delete(_ordersKey);
  }
}