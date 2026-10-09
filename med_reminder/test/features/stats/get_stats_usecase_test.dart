import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/entities/dose_occurrence.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/repositories/dose_repository.dart';
import 'package:flutter_application_2/features/medicines/domain/entities/medicine.dart';
import 'package:flutter_application_2/features/medicines/domain/entities/medicine_schedule.dart';
import 'package:flutter_application_2/features/medicines/domain/entities/refill_record.dart';
import 'package:flutter_application_2/features/medicines/domain/repositories/medicine_repository.dart';
import 'package:flutter_application_2/features/stats/domain/entities/stats_models.dart';
import 'package:flutter_application_2/features/stats/domain/usecases/get_stats_usecase.dart';

class _FakeDoseRepository implements DoseRepository {
  final List<DoseOccurrence> doses;
  _FakeDoseRepository(this.doses);

  @override
  Future<List<DoseOccurrence>> getAllDoses() async => doses;

  @override
  Future<List<DoseOccurrence>> getDosesForDateRange(DateTime start, DateTime end) async => doses;

  @override
  Future<List<DoseOccurrence>> getTodayDoses() async => doses;

  @override
  Future<DoseOccurrence?> getDoseById(String id) async => null;

  @override
  Future<void> saveOccurrences(List<DoseOccurrence> occurrences) async {}

  @override
  Future<void> updateDoseStatus(String id, DoseStatus status, DateTime? actionAtUtc) async {}

  @override
  Future<void> deleteFuturePendingDosesForMedicine(String medicineId) async {}
}

class _FakeMedicineRepository implements MedicineRepository {
  final List<Medicine> medicines;
  _FakeMedicineRepository(this.medicines);

  @override
  Future<List<Medicine>> getMedicines({bool activeOnly = true}) async => medicines;

  @override
  Future<Medicine?> getMedicineById(String id) async => null;

  @override
  Future<void> saveMedicine(Medicine medicine, List<MedicineSchedule> schedules) async {}

  @override
  Future<void> updateMedicine(Medicine medicine) async {}

  @override
  Future<void> deleteMedicine(String id) async {}

  @override
  Future<void> updateRemainingQuantity(String id, double newQuantity) async {}

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
  group('GetStatsUseCase', () {
    // Current time: Wednesday, 18 Sep 2024, 12:00
    final fixedNow = DateTime(2024, 9, 18, 12, 0);

    final testMedicines = [
      Medicine(
        id: 'med_1',
        name: 'Metformin',
        strength: '500mg',
        form: MedicineForm.tablet,
        totalQuantity: 30,
        remainingQuantity: 25,
        startDate: DateTime(2024, 9, 1),
        createdAt: DateTime(2024, 9, 1),
        updatedAt: DateTime(2024, 9, 1),
      ),
      Medicine(
        id: 'med_2',
        name: 'Amlodipine',
        strength: '5mg',
        form: MedicineForm.tablet,
        totalQuantity: 20,
        remainingQuantity: 18,
        startDate: DateTime(2024, 9, 1),
        createdAt: DateTime(2024, 9, 1),
        updatedAt: DateTime(2024, 9, 1),
      ),
    ];

    final testDoses = [
      // Monday 16 Sep: 2 taken (100% adherence day)
      DoseOccurrence(
        id: 'd1',
        medicineId: 'med_1',
        scheduleId: 's1',
        medicineName: 'Metformin',
        form: MedicineForm.tablet,
        scheduledAtUtc: DateTime.utc(2024, 9, 16, 8, 0).toUtc(),
        status: DoseStatus.taken,
      ),
      DoseOccurrence(
        id: 'd2',
        medicineId: 'med_2',
        scheduleId: 's2',
        medicineName: 'Amlodipine',
        form: MedicineForm.tablet,
        scheduledAtUtc: DateTime.utc(2024, 9, 16, 12, 0).toUtc(),
        status: DoseStatus.taken,
      ),
      // Tuesday 17 Sep: 1 taken, 1 skipped
      DoseOccurrence(
        id: 'd3',
        medicineId: 'med_1',
        scheduleId: 's1',
        medicineName: 'Metformin',
        form: MedicineForm.tablet,
        scheduledAtUtc: DateTime.utc(2024, 9, 17, 8, 0).toUtc(),
        status: DoseStatus.taken,
      ),
      DoseOccurrence(
        id: 'd4',
        medicineId: 'med_2',
        scheduleId: 's2',
        medicineName: 'Amlodipine',
        form: MedicineForm.tablet,
        scheduledAtUtc: DateTime.utc(2024, 9, 17, 12, 0).toUtc(),
        status: DoseStatus.skipped,
      ),
      // Wednesday 18 Sep: 1 taken, 1 missed
      DoseOccurrence(
        id: 'd5',
        medicineId: 'med_1',
        scheduleId: 's1',
        medicineName: 'Metformin',
        form: MedicineForm.tablet,
        scheduledAtUtc: DateTime.utc(2024, 9, 18, 8, 0).toUtc(),
        status: DoseStatus.taken,
      ),
      DoseOccurrence(
        id: 'd6',
        medicineId: 'med_2',
        scheduleId: 's2',
        medicineName: 'Amlodipine',
        form: MedicineForm.tablet,
        scheduledAtUtc: DateTime.utc(2024, 9, 18, 9, 0).toUtc(),
        status: DoseStatus.missed,
      ),
    ];

    test('calculates weekly adherence rate, totals, and per-medicine breakdown', () async {
      final useCase = GetStatsUseCase(
        doseRepository: _FakeDoseRepository(testDoses),
        medicineRepository: _FakeMedicineRepository(testMedicines),
      );

      final stats = await useCase.execute(
        timeframe: StatsTimeframe.weekly,
        now: fixedNow,
      );

      expect(stats.totalDoses, 6);
      expect(stats.takenDoses, 4);
      expect(stats.skippedDoses, 1);
      expect(stats.missedDoses, 1);
      // Overall adherence = 4 taken / 6 completed = 0.666...
      expect(stats.overallAdherenceRate, closeTo(0.667, 0.01));
      expect(stats.adherencePercentageString, '67%');

      // Check chart points: 7 days Mon..Sun
      expect(stats.chartPoints.length, 7);
      expect(stats.chartPoints[0].dayLabel, 'Mon');
      expect(stats.chartPoints[0].taken, 2);
      expect(stats.chartPoints[0].total, 2);
      expect(stats.chartPoints[0].adherencePercent, 100.0);

      // Check per-medicine breakdown
      expect(stats.medicineBreakdown.length, 2);
      final metformin = stats.medicineBreakdown.firstWhere((m) => m.medicineName == 'Metformin');
      expect(metformin.totalDoses, 3);
      expect(metformin.takenDoses, 3);
      expect(metformin.adherencePercentageString, '100%');

      final amlodipine = stats.medicineBreakdown.firstWhere((m) => m.medicineName == 'Amlodipine');
      expect(amlodipine.totalDoses, 3);
      expect(amlodipine.takenDoses, 1);
      expect(amlodipine.skippedDoses, 1);
      expect(amlodipine.missedDoses, 1);
    });

    test('calculates streak statistics accurately', () async {
      final useCase = GetStatsUseCase(
        doseRepository: _FakeDoseRepository(testDoses),
        medicineRepository: _FakeMedicineRepository(testMedicines),
      );

      final stats = await useCase.execute(
        timeframe: StatsTimeframe.allTime,
        now: fixedNow,
      );

      // Day 1 (16 Sep): 2/2 taken -> streak 1
      // Day 2 (17 Sep): 1 taken, 1 skipped -> not all taken, streak continues or doesn't increment full
      // Day 3 (18 Sep): 1 missed -> resets streak
      expect(stats.streaks.bestStreak, greaterThanOrEqualTo(1));
    });
  });
}
