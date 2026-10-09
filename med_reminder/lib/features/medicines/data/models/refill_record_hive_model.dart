import 'package:hive/hive.dart';
import '../../../../core/local/hive_service.dart';
import '../../domain/entities/refill_record.dart';

class RefillRecordHiveModel {
  final String id;
  final String medicineId;
  final double addedQuantity;
  final String refilledAtIso;

  const RefillRecordHiveModel({
    required this.id,
    required this.medicineId,
    required this.addedQuantity,
    required this.refilledAtIso,
  });

  RefillRecord toDomain() {
    return RefillRecord(
      id: id,
      medicineId: medicineId,
      addedQuantity: addedQuantity,
      refilledAt: DateTime.parse(refilledAtIso),
    );
  }

  factory RefillRecordHiveModel.fromDomain(RefillRecord record) {
    return RefillRecordHiveModel(
      id: record.id,
      medicineId: record.medicineId,
      addedQuantity: record.addedQuantity,
      refilledAtIso: record.refilledAt.toIso8601String(),
    );
  }
}

class RefillRecordHiveModelAdapter extends TypeAdapter<RefillRecordHiveModel> {
  @override
  final int typeId = HiveService.refillRecordTypeId;

  @override
  RefillRecordHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RefillRecordHiveModel(
      id: fields[0] as String,
      medicineId: fields[1] as String,
      addedQuantity: (fields[2] as num).toDouble(),
      refilledAtIso: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RefillRecordHiveModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.medicineId)
      ..writeByte(2)..write(obj.addedQuantity)
      ..writeByte(3)..write(obj.refilledAtIso);
  }
}
