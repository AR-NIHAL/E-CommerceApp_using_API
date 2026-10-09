import 'package:hive/hive.dart';
import '../../../../core/local/hive_service.dart';
import 'package:flutter_application_2/features/medicines/domain/entities/medicine.dart';
import '../../domain/entities/dose_occurrence.dart';

class DoseOccurrenceHiveModel {
  final String id;
  final String medicineId;
  final String scheduleId;
  final String medicineName;
  final String? strength;
  final String form;
  final String? instruction;
  final String scheduledAtUtcIso;
  final String status;
  final String? actionAtUtcIso;
  final double plannedQuantity;
  final String doseUnit;

  const DoseOccurrenceHiveModel({
    required this.id,
    required this.medicineId,
    required this.scheduleId,
    required this.medicineName,
    this.strength,
    required this.form,
    this.instruction,
    required this.scheduledAtUtcIso,
    required this.status,
    this.actionAtUtcIso,
    required this.plannedQuantity,
    required this.doseUnit,
  });

  DoseOccurrence toDomain() {
    return DoseOccurrence(
      id: id,
      medicineId: medicineId,
      scheduleId: scheduleId,
      medicineName: medicineName,
      strength: strength,
      form: MedicineForm.fromString(form),
      instruction: instruction,
      scheduledAtUtc: DateTime.parse(scheduledAtUtcIso),
      status: DoseStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => DoseStatus.pending,
      ),
      actionAtUtc: actionAtUtcIso != null ? DateTime.parse(actionAtUtcIso!) : null,
      plannedQuantity: plannedQuantity,
      doseUnit: doseUnit,
    );
  }

  factory DoseOccurrenceHiveModel.fromDomain(DoseOccurrence dose) {
    return DoseOccurrenceHiveModel(
      id: dose.id,
      medicineId: dose.medicineId,
      scheduleId: dose.scheduleId,
      medicineName: dose.medicineName,
      strength: dose.strength,
      form: dose.form.name,
      instruction: dose.instruction,
      scheduledAtUtcIso: dose.scheduledAtUtc.toIso8601String(),
      status: dose.status.name,
      actionAtUtcIso: dose.actionAtUtc?.toIso8601String(),
      plannedQuantity: dose.plannedQuantity,
      doseUnit: dose.doseUnit,
    );
  }
}

class DoseOccurrenceHiveModelAdapter extends TypeAdapter<DoseOccurrenceHiveModel> {
  @override
  final int typeId = HiveService.doseOccurrenceTypeId;

  @override
  DoseOccurrenceHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DoseOccurrenceHiveModel(
      id: fields[0] as String,
      medicineId: fields[1] as String,
      scheduleId: fields[2] as String,
      medicineName: fields[3] as String,
      strength: fields[4] as String?,
      form: fields[5] as String,
      instruction: fields[6] as String?,
      scheduledAtUtcIso: fields[7] as String,
      status: fields[8] as String,
      actionAtUtcIso: fields[9] as String?,
      plannedQuantity: (fields[10] as num).toDouble(),
      doseUnit: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DoseOccurrenceHiveModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.medicineId)
      ..writeByte(2)..write(obj.scheduleId)
      ..writeByte(3)..write(obj.medicineName)
      ..writeByte(4)..write(obj.strength)
      ..writeByte(5)..write(obj.form)
      ..writeByte(6)..write(obj.instruction)
      ..writeByte(7)..write(obj.scheduledAtUtcIso)
      ..writeByte(8)..write(obj.status)
      ..writeByte(9)..write(obj.actionAtUtcIso)
      ..writeByte(10)..write(obj.plannedQuantity)
      ..writeByte(11)..write(obj.doseUnit);
  }
}
