import 'package:hive/hive.dart';

import '../../../features/products/domain/entities/product.dart';

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 1;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Product(
      id: fields[0] as int,
      title: fields[1] as String,
      description: fields[2] as String? ?? '',
      category: fields[3] as String? ?? '',
      price: fields[4] as double,
      discountPercentage: fields[5] as double? ?? 0,
      rating: fields[6] as double? ?? 0,
      stock: fields[7] as int? ?? 0,
      brand: fields[8] as String? ?? '',
      thumbnail: fields[9] as String? ?? '',
      images: (fields[10] as List?)?.cast<String>() ?? const [],
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.discountPercentage)
      ..writeByte(6)
      ..write(obj.rating)
      ..writeByte(7)
      ..write(obj.stock)
      ..writeByte(8)
      ..write(obj.brand)
      ..writeByte(9)
      ..write(obj.thumbnail)
      ..writeByte(10)
      ..write(obj.images);
  }
}
