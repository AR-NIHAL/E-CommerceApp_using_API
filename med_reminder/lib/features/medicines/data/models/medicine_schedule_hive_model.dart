import 'package:hive/hive.dart';
import '../../../../core/local/hive_service.dart';
import '../../domain/entities/medicine_schedule.dart';

class MedicineScheduleHiveModel {
  final String id;
  final String medicineId;
  final int hour;
  final int minute;
  final double doseQuantity;
  final String doseUnit;
  final String? instruction;
  final List<int> weekDays;
  final bool reminderEnabled;

  const MedicineScheduleHiveModel({
    required this.id,
    required this.medicineId,
    required this.hour,
    required this.minute,
    required this.doseQuantity,
    required this.doseUnit,
    this.instruction,
    required this.weekDays,
    required this.reminderEnabled,
  });

  MedicineSchedule toDomain() {
    return MedicineSchedule(
      id: id,
      medicineId: medicineId,
      hour: hour,
      minute: minute,
      doseQuantity: doseQuantity,
      doseUnit: doseUnit,
      instruction: instruction,
      weekDays: weekDays.toSet(),
      reminderEnabled: reminderEnabled,
    );
  }

  factory MedicineScheduleHiveModel.fromDomain(MedicineSchedule schedule) {
    return MedicineScheduleHiveModel(
      id: schedule.id,
      medicineId: schedule.medicineId,
      hour: schedule.hour,
      minute: schedule.minute,
      doseQuantity: schedule.doseQuantity,
      doseUnit: schedule.doseUnit,
      instruction: schedule.instruction,
      weekDays: schedule.weekDays.toList(),
      reminderEnabled: schedule.reminderEnabled,
    );
  }
}

class MedicineScheduleHiveModelAdapter extends TypeAdapter<MedicineScheduleHiveModel> {
  @override
  final int typeId = HiveService.medicineScheduleTypeId;

  @override
  MedicineScheduleHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicineScheduleHiveModel(
      id: fields[0] as String,
      medicineId: fields[1] as String,
      hour: fields[2] as int,
      minute: fields[3] as int,
      doseQuantity: (fields[4] as num).toDouble(),
      doseUnit: fields[5] as String,
      instruction: fields[6] as String?,
      weekDays: (fields[7] as List).cast<int>(),
      reminderEnabled: fields[8] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, MedicineScheduleHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.medicineId)
      ..writeByte(2)..write(obj.hour)
      ..writeByte(3)..write(obj.minute)
      ..writeByte(4)..write(obj.doseQuantity)
      ..writeByte(5)..write(obj.doseUnit)
      ..writeByte(6)..write(obj.instruction)
      ..writeByte(7)..write(obj.weekDays)
      ..writeByte(8)..write(obj.reminderEnabled);
  }
}
