import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/entities/dose_occurrence.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/repositories/dose_repository.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/services/dose_occurrence_generator.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/usecases/mark_dose_taken_usecase.dart';
import 'package:flutter_application_2/features/medicines/domain/entities/medicine.dart';
import 'package:flutter_application_2/features/medicines/domain/entities/medicine_schedule.dart';
import 'package:flutter_application_2/features/medicines/domain/entities/refill_record.dart';
import 'package:flutter_application_2/features/medicines/domain/repositories/medicine_repository.dart';

class FakeDoseRepository implements DoseRepository {
  final Map<String, DoseOccurrence> doses = {};

  @override
  Future<List<DoseOccurrence>> getDosesForDateRange(DateTime start, DateTime end) async {
    return doses.values.where((d) {
      final local = d.scheduledAtLocal;
      return !local.isBefore(start) && !local.isAfter(end);
    }).toList();
  }

  @override
  Future<List<DoseOccurrence>> getTodayDoses() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return getDosesForDateRange(start, end);
  }

  @override
  Future<DoseOccurrence?> getDoseById(String id) async => doses[id];

  @override
  Future<void> saveOccurrences(List<DoseOccurrence> occurrences) async {
    for (final occ in occurrences) {
      final existing = doses[occ.id];
      if (existing != null &&
          (existing.status == DoseStatus.taken || existing.status == DoseStatus.skipped)) {
        continue;
      }
      doses[occ.id] = occ;
    }
  }

  @override
  Future<void> updateDoseStatus(String id, DoseStatus status, DateTime? actionAtUtc) async {
    final dose = doses[id];
    if (dose != null) {
      doses[id] = dose.copyWith(status: status, actionAtUtc: actionAtUtc);
    }
  }

  @override
  Future<void> deleteFuturePendingDosesForMedicine(String medicineId) async {
    final now = DateTime.now().toUtc();
    doses.removeWhere((key, d) =>
        d.medicineId == medicineId && d.status == DoseStatus.pending && d.scheduledAtUtc.isAfter(now));
  }

  @override
  Future<List<DoseOccurrence>> getAllDoses() async => doses.values.toList();
}

class FakeMedRepository implements MedicineRepository {
  final Map<String, Medicine> medicines = {};

  @override
  Future<Medicine?> getMedicineById(String id) async => medicines[id];

  @override
  Future<void> updateRemainingQuantity(String id, double newQuantity) async {
    final med = medicines[id];
    if (med != null) {
      medicines[id] = med.copyWith(remainingQuantity: newQuantity);
    }
  }

  @override
  Future<List<Medicine>> getMedicines({bool activeOnly = true}) async => medicines.values.toList();
  @override
  Future<void> saveMedicine(Medicine medicine, List<MedicineSchedule> schedules) async {
    medicines[medicine.id] = medicine;
  }
  @override
  Future<void> updateMedicine(Medicine medicine) async {
    medicines[medicine.id] = medicine;
  }
  @override
  Future<void> deleteMedicine(String id) async {}
  @override
  Future<List<MedicineSchedule>> getSchedulesForMedicine(String medicineId) async => [];
  @override
  Future<List<MedicineSchedule>> getAllActiveSchedules() async => [];
  @override
  Future<void> recordRefill(RefillRecord record) async {}
  @override
  Future<List<RefillRecord>> getRefillRecords(String medicineId) async => [];
}

void main() {
  const generator = DoseOccurrenceGenerator();

  group('DoseOccurrenceGenerator', () {
    final startDate = DateTime(2026, 9, 1);
    final medicine = Medicine(
      id: 'med-metformin',
      name: 'Metformin',
      strength: '500mg',
      form: MedicineForm.tablet,
      totalQuantity: 60,
      remainingQuantity: 60,
      startDate: startDate,
      createdAt: startDate,
      updatedAt: startDate,
    );

    test('generates exact occurrences for daily schedules across 7 days', () {
      final schedules = [
        const MedicineSchedule(
          id: 's-morning',
          medicineId: 'med-metformin',
          hour: 8,
          minute: 0,
          instruction: 'After breakfast',
        ),
        const MedicineSchedule(
          id: 's-night',
          medicineId: 'med-metformin',
          hour: 20,
          minute: 0,
          instruction: 'After dinner',
        ),
      ];

      final from = DateTime(2026, 9, 1);
      final until = DateTime(2026, 9, 7); // 7 days inclusive

      final occurrences = generator.generate(
        medicine: medicine,
        schedules: schedules,
        from: from,
        until: until,
      );

      // 7 days * 2 doses/day = 14 occurrences
      expect(occurrences.length, 14);

      // Verify deterministic ID format
      expect(occurrences.first.id, 'occ_s-morning_2026-09-01_0800');
      expect(occurrences[1].id, 'occ_s-night_2026-09-01_2000');
    });

    test('respects weekday filters (e.g., only Monday and Wednesday)', () {
      final schedules = [
        const MedicineSchedule(
          id: 's-mon-wed',
          medicineId: 'med-metformin',
          hour: 10,
          minute: 0,
          weekDays: {DateTime.monday, DateTime.wednesday},
        ),
      ];

      // 2026-09-01 is Tuesday, 2026-09-07 is Monday
      final from = DateTime(2026, 9, 1);
      final until = DateTime(2026, 9, 7);

      final occurrences = generator.generate(
        medicine: medicine,
        schedules: schedules,
        from: from,
        until: until,
      );

      // Within Sept 1 to Sept 7:
      // Sept 2 = Wed
      // Sept 7 = Mon
      // Total = 2 occurrences
      expect(occurrences.length, 2);
      expect(occurrences[0].scheduledAtLocal.weekday, DateTime.wednesday);
      expect(occurrences[1].scheduledAtLocal.weekday, DateTime.monday);
    });
  });

  group('DoseOccurrence.effectiveStatus', () {
    final baseUtc = DateTime.utc(2026, 9, 16, 8, 0); // 8:00 AM UTC
    final dose = DoseOccurrence(
      id: 'dose-1',
      medicineId: 'med-1',
      scheduleId: 's-1',
      medicineName: 'Metformin',
      form: MedicineForm.tablet,
      scheduledAtUtc: baseUtc,
    );

    test('returns taken when status is taken regardless of time', () {
      final takenDose = dose.copyWith(status: DoseStatus.taken);
      final futureTime = dose.scheduledAtLocal.add(const Duration(hours: 10));
      expect(takenDose.effectiveStatus(futureTime), DoseStatus.taken);
    });

    test('returns skipped when status is skipped regardless of time', () {
      final skippedDose = dose.copyWith(status: DoseStatus.skipped);
      final futureTime = dose.scheduledAtLocal.add(const Duration(hours: 10));
      expect(skippedDose.effectiveStatus(futureTime), DoseStatus.skipped);
    });

    test('returns missed if pending and now is after grace period (2 hours)', () {
      // 2 hours 1 minute after scheduled time
      final lateTime = dose.scheduledAtLocal.add(const Duration(hours: 2, minutes: 1));
      expect(dose.effectiveStatus(lateTime), DoseStatus.missed);
    });

    test('returns pending if within grace period', () {
      // 1 hour after scheduled time
      final withinGrace = dose.scheduledAtLocal.add(const Duration(hours: 1));
      expect(dose.effectiveStatus(withinGrace), DoseStatus.pending);
    });
  });

  group('MarkDoseTakenUseCase', () {
    late FakeDoseRepository doseRepo;
    late FakeMedRepository medRepo;
    late MarkDoseTakenUseCase useCase;

    setUp(() {
      doseRepo = FakeDoseRepository();
      medRepo = FakeMedRepository();
      useCase = MarkDoseTakenUseCase(
        doseRepository: doseRepo,
        medicineRepository: medRepo,
      );
    });

    test('marks dose taken and decreases inventory by plannedQuantity', () async {
      final now = DateTime.now();
      final med = Medicine(
        id: 'med-1',
        name: 'Metformin',
        form: MedicineForm.tablet,
        totalQuantity: 30,
        remainingQuantity: 30,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );
      await medRepo.saveMedicine(med, []);

      final dose = DoseOccurrence(
        id: 'occ-1',
        medicineId: 'med-1',
        scheduleId: 's-1',
        medicineName: 'Metformin',
        form: MedicineForm.tablet,
        scheduledAtUtc: now.toUtc(),
        plannedQuantity: 1.0,
      );
      await doseRepo.saveOccurrences([dose]);

      // Execute Mark Taken
      await useCase.execute('occ-1');

      final updatedDose = await doseRepo.getDoseById('occ-1');
      expect(updatedDose!.status, DoseStatus.taken);

      final updatedMed = await medRepo.getMedicineById('med-1');
      expect(updatedMed!.remainingQuantity, 29.0);

      // Test idempotency: Calling it again MUST NOT decrease quantity again
      await useCase.execute('occ-1');
      final doubleCheckMed = await medRepo.getMedicineById('med-1');
      expect(doubleCheckMed!.remainingQuantity, 29.0); // Still 29.0!
    });
  });
}
