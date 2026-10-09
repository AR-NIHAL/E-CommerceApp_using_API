import 'package:hive/hive.dart';
import '../models/dose_occurrence_hive_model.dart';
import '../../domain/entities/dose_occurrence.dart';
import '../../domain/repositories/dose_repository.dart';

class DoseRepositoryImpl implements DoseRepository {
  final Box<DoseOccurrenceHiveModel> _doseBox;

  DoseRepositoryImpl({
    required Box<DoseOccurrenceHiveModel> doseBox,
  }) : _doseBox = doseBox;

  @override
  Future<List<DoseOccurrence>> getDosesForDateRange(DateTime start, DateTime end) async {
    final startUtc = start.toUtc();
    final endUtc = end.toUtc();

    final matches = _doseBox.values.where((model) {
      final scheduledUtc = DateTime.parse(model.scheduledAtUtcIso);
      return !scheduledUtc.isBefore(startUtc) && !scheduledUtc.isAfter(endUtc);
    }).toList();

    // Sort chronologically ascending
    matches.sort((a, b) => a.scheduledAtUtcIso.compareTo(b.scheduledAtUtcIso));
    return matches.map((m) => m.toDomain()).toList();
  }

  @override
  Future<List<DoseOccurrence>> getTodayDoses() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    return getDosesForDateRange(startOfDay, endOfDay);
  }

  @override
  Future<DoseOccurrence?> getDoseById(String id) async {
    final model = _doseBox.get(id);
    return model?.toDomain();
  }

  @override
  Future<void> saveOccurrences(List<DoseOccurrence> occurrences) async {
    for (final occ in occurrences) {
      final existing = _doseBox.get(occ.id);
      // Preserve history: never overwrite an occurrence that was already taken or skipped
      if (existing != null &&
          (existing.status == DoseStatus.taken.name ||
              existing.status == DoseStatus.skipped.name)) {
        continue;
      }
      final model = DoseOccurrenceHiveModel.fromDomain(occ);
      await _doseBox.put(occ.id, model);
    }
  }

  @override
  Future<void> updateDoseStatus(String id, DoseStatus status, DateTime? actionAtUtc) async {
    final existing = _doseBox.get(id);
    if (existing != null) {
      final updated = DoseOccurrenceHiveModel(
        id: existing.id,
        medicineId: existing.medicineId,
        scheduleId: existing.scheduleId,
        medicineName: existing.medicineName,
        strength: existing.strength,
        form: existing.form,
        instruction: existing.instruction,
        scheduledAtUtcIso: existing.scheduledAtUtcIso,
        status: status.name,
        actionAtUtcIso: actionAtUtc?.toIso8601String(),
        plannedQuantity: existing.plannedQuantity,
        doseUnit: existing.doseUnit,
      );
      await _doseBox.put(id, updated);
    }
  }

  @override
  Future<void> deleteFuturePendingDosesForMedicine(String medicineId) async {
    final nowUtc = DateTime.now().toUtc();
    final keysToDelete = _doseBox.values
        .where((model) {
          if (model.medicineId != medicineId) return false;
          if (model.status != DoseStatus.pending.name) return false;
          final scheduledUtc = DateTime.parse(model.scheduledAtUtcIso);
          return scheduledUtc.isAfter(nowUtc);
        })
        .map((model) => model.id)
        .toList();

    await _doseBox.deleteAll(keysToDelete);
  }

  @override
  Future<List<DoseOccurrence>> getAllDoses() async {
    final list = _doseBox.values.toList();
    list.sort((a, b) => a.scheduledAtUtcIso.compareTo(b.scheduledAtUtcIso));
    return list.map((m) => m.toDomain()).toList();
  }
}
