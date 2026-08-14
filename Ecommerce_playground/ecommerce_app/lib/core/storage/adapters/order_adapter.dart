import 'package:hive/hive.dart';

import '../../../features/cart/domain/entities/cart_item.dart';
import '../../../features/checkout/domain/entities/order.dart';
import '../../../features/checkout/domain/entities/payment_method.dart';

class OrderAdapter extends TypeAdapter<Order> {
  @override
  final int typeId = 3;

  @override
  Order read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Order(
      id: fields[0] as String,
      placedAt: fields[1] as DateTime,
      items: (fields[2] as List).cast<CartItem>(),
      fullName: fields[3] as String,
      phone: fields[4] as String,
      address: fields[5] as String,
      city: fields[6] as String,
      state: fields[7] as String?,
      zip: fields[8] as String?,
      paymentMethod:
          PaymentMethod.values.byName(fields[9] as String),
      subtotal: fields[10] as double,
      shipping: fields[11] as double,
      total: fields[12] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Order obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.placedAt)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.fullName)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.city)
      ..writeByte(7)
      ..write(obj.state)
      ..writeByte(8)
      ..write(obj.zip)
      ..writeByte(9)
      ..write(obj.paymentMethod.name)
      ..writeByte(10)
      ..write(obj.subtotal)
      ..writeByte(11)
      ..write(obj.shipping)
      ..writeByte(12)
      ..write(obj.total);
  }
}