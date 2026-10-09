import 'package:hive/hive.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/entities/medicine_schedule.dart';
import '../../domain/entities/refill_record.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../models/medicine_hive_model.dart';
import '../models/medicine_schedule_hive_model.dart';
import '../models/refill_record_hive_model.dart';

class MedicineRepositoryImpl implements MedicineRepository {
  final Box<MedicineHiveModel> _medicinesBox;
  final Box<MedicineScheduleHiveModel> _schedulesBox;
  final Box<RefillRecordHiveModel> _refillsBox;

  MedicineRepositoryImpl({
    required Box<MedicineHiveModel> medicinesBox,
    required Box<MedicineScheduleHiveModel> schedulesBox,
    required Box<RefillRecordHiveModel> refillsBox,
  })  : _medicinesBox = medicinesBox,
        _schedulesBox = schedulesBox,
        _refillsBox = refillsBox;

  @override
  Future<List<Medicine>> getMedicines({bool activeOnly = true}) async {
    final models = _medicinesBox.values.where((m) => !activeOnly || m.isActive).toList();
    // Sort by createdAt descending
    models.sort((a, b) => b.createdAtIso.compareTo(a.createdAtIso));
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<Medicine?> getMedicineById(String id) async {
    final model = _medicinesBox.get(id);
    return model?.toDomain();
  }

  @override
  Future<void> saveMedicine(Medicine medicine, List<MedicineSchedule> schedules) async {
    // 1. Save medicine
    final medModel = MedicineHiveModel.fromDomain(medicine);
    await _medicinesBox.put(medicine.id, medModel);

    // 2. Remove existing schedules for this medicine
    final existingKeys = _schedulesBox.values
        .where((s) => s.medicineId == medicine.id)
        .map((s) => s.id)
        .toList();
    await _schedulesBox.deleteAll(existingKeys);

    // 3. Save new schedules
    for (final schedule in schedules) {
      final schedModel = MedicineScheduleHiveModel.fromDomain(schedule);
      await _schedulesBox.put(schedule.id, schedModel);
    }
  }

  @override
  Future<void> updateMedicine(Medicine medicine) async {
    final model = MedicineHiveModel.fromDomain(medicine);
    await _medicinesBox.put(medicine.id, model);
  }

  @override
  Future<void> deleteMedicine(String id) async {
    final model = _medicinesBox.get(id);
    if (model != null) {
      final updated = MedicineHiveModel(
        id: model.id,
        name: model.name,
        strength: model.strength,
        form: model.form,
        category: model.category,
        totalQuantity: model.totalQuantity,
        remainingQuantity: model.remainingQuantity,
        startDateIso: model.startDateIso,
        endDateIso: model.endDateIso,
        notes: model.notes,
        refillThreshold: model.refillThreshold,
        isActive: false, // Soft delete
        createdAtIso: model.createdAtIso,
        updatedAtIso: DateTime.now().toUtc().toIso8601String(),
      );
      await _medicinesBox.put(id, updated);
    }
  }

  @override
  Future<void> updateRemainingQuantity(String id, double newQuantity) async {
    final model = _medicinesBox.get(id);
    if (model != null) {
      final updated = MedicineHiveModel(
        id: model.id,
        name: model.name,
        strength: model.strength,
        form: model.form,
        category: model.category,
        totalQuantity: model.totalQuantity,
        remainingQuantity: newQuantity < 0 ? 0 : newQuantity,
        startDateIso: model.startDateIso,
        endDateIso: model.endDateIso,
        notes: model.notes,
        refillThreshold: model.refillThreshold,
        isActive: model.isActive,
        createdAtIso: model.createdAtIso,
        updatedAtIso: DateTime.now().toUtc().toIso8601String(),
      );
      await _medicinesBox.put(id, updated);
    }
  }

  @override
  Future<List<MedicineSchedule>> getSchedulesForMedicine(String medicineId) async {
    final models = _schedulesBox.values.where((s) => s.medicineId == medicineId).toList();
    // Sort schedules by time (hour, then minute)
    models.sort((a, b) {
      final hourCompare = a.hour.compareTo(b.hour);
      if (hourCompare != 0) return hourCompare;
      return a.minute.compareTo(b.minute);
    });
    return models.map((s) => s.toDomain()).toList();
  }

  @override
  Future<List<MedicineSchedule>> getAllActiveSchedules() async {
    final activeMedIds = _medicinesBox.values
        .where((m) => m.isActive)
        .map((m) => m.id)
        .toSet();

    final models = _schedulesBox.values
        .where((s) => activeMedIds.contains(s.medicineId) && s.reminderEnabled)
        .toList();

    return models.map((s) => s.toDomain()).toList();
  }

  @override
  Future<void> recordRefill(RefillRecord record) async {
    final model = RefillRecordHiveModel.fromDomain(record);
    await _refillsBox.put(record.id, model);
  }

  @override
  Future<List<RefillRecord>> getRefillRecords(String medicineId) async {
    final models = _refillsBox.values.where((r) => r.medicineId == medicineId).toList();
    models.sort((a, b) => b.refilledAtIso.compareTo(a.refilledAtIso));
    return models.map((r) => r.toDomain()).toList();
  }
}
