import 'package:hive/hive.dart';
import '../../../../core/local/hive_service.dart';
import '../../domain/entities/medicine.dart';

class MedicineHiveModel {
  final String id;
  final String name;
  final String? strength;
  final String form; // serialized from MedicineForm enum
  final String? category;
  final double totalQuantity;
  final double remainingQuantity;
  final String startDateIso;
  final String? endDateIso;
  final String? notes;
  final double refillThreshold;
  final bool isActive;
  final String createdAtIso;
  final String updatedAtIso;

  const MedicineHiveModel({
    required this.id,
    required this.name,
    this.strength,
    required this.form,
    this.category,
    required this.totalQuantity,
    required this.remainingQuantity,
    required this.startDateIso,
    this.endDateIso,
    this.notes,
    required this.refillThreshold,
    required this.isActive,
    required this.createdAtIso,
    required this.updatedAtIso,
  });

  Medicine toDomain() {
    return Medicine(
      id: id,
      name: name,
      strength: strength,
      form: MedicineForm.fromString(form),
      category: category,
      totalQuantity: totalQuantity,
      remainingQuantity: remainingQuantity,
      startDate: DateTime.parse(startDateIso),
      endDate: endDateIso != null ? DateTime.parse(endDateIso!) : null,
      notes: notes,
      refillThreshold: refillThreshold,
      isActive: isActive,
      createdAt: DateTime.parse(createdAtIso),
      updatedAt: DateTime.parse(updatedAtIso),
    );
  }

  factory MedicineHiveModel.fromDomain(Medicine medicine) {
    return MedicineHiveModel(
      id: medicine.id,
      name: medicine.name,
      strength: medicine.strength,
      form: medicine.form.name,
      category: medicine.category,
      totalQuantity: medicine.totalQuantity,
      remainingQuantity: medicine.remainingQuantity,
      startDateIso: medicine.startDate.toIso8601String(),
      endDateIso: medicine.endDate?.toIso8601String(),
      notes: medicine.notes,
      refillThreshold: medicine.refillThreshold,
      isActive: medicine.isActive,
      createdAtIso: medicine.createdAt.toIso8601String(),
      updatedAtIso: medicine.updatedAt.toIso8601String(),
    );
  }
}

class MedicineHiveModelAdapter extends TypeAdapter<MedicineHiveModel> {
  @override
  final int typeId = HiveService.medicineTypeId;

  @override
  MedicineHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicineHiveModel(
      id: fields[0] as String,
      name: fields[1] as String,
      strength: fields[2] as String?,
      form: fields[3] as String,
      category: fields[4] as String?,
      totalQuantity: (fields[5] as num).toDouble(),
      remainingQuantity: (fields[6] as num).toDouble(),
      startDateIso: fields[7] as String,
      endDateIso: fields[8] as String?,
      notes: fields[9] as String?,
      refillThreshold: (fields[10] as num).toDouble(),
      isActive: fields[11] as bool? ?? true,
      createdAtIso: fields[12] as String,
      updatedAtIso: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MedicineHiveModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.strength)
      ..writeByte(3)..write(obj.form)
      ..writeByte(4)..write(obj.category)
      ..writeByte(5)..write(obj.totalQuantity)
      ..writeByte(6)..write(obj.remainingQuantity)
      ..writeByte(7)..write(obj.startDateIso)
      ..writeByte(8)..write(obj.endDateIso)
      ..writeByte(9)..write(obj.notes)
      ..writeByte(10)..write(obj.refillThreshold)
      ..writeByte(11)..write(obj.isActive)
      ..writeByte(12)..write(obj.createdAtIso)
      ..writeByte(13)..write(obj.updatedAtIso);
  }
}
