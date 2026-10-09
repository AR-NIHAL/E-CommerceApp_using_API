import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/entities/dose_occurrence.dart';
import 'package:flutter_application_2/features/history/domain/entities/history_models.dart';
import 'package:flutter_application_2/features/medicines/domain/entities/medicine.dart';

void main() {
  group('DayDoseStatus calculation', () {
    final now = DateTime(2024, 9, 16, 12, 0);

    test('returns none for empty doses', () {
      expect(DayDoseStatus.fromDoses([], now: now), DayDoseStatus.none);
    });

    test('returns allTaken when all doses have status taken', () {
      final doses = [
        DoseOccurrence(
          id: '1',
          medicineId: 'm1',
          scheduleId: 's1',
          medicineName: 'Aspirin',
          form: MedicineForm.tablet,
          scheduledAtUtc: DateTime.utc(2024, 9, 16, 8, 0),
          status: DoseStatus.taken,
        ),
        DoseOccurrence(
          id: '2',
          medicineId: 'm1',
          scheduleId: 's2',
          medicineName: 'Aspirin',
          form: MedicineForm.tablet,
          scheduledAtUtc: DateTime.utc(2024, 9, 16, 14, 0),
          status: DoseStatus.taken,
        ),
      ];

      expect(DayDoseStatus.fromDoses(doses, now: now), DayDoseStatus.allTaken);
    });

    test('returns hasMissed when at least one dose is missed', () {
      final doses = [
        DoseOccurrence(
          id: '1',
          medicineId: 'm1',
          scheduleId: 's1',
          medicineName: 'Aspirin',
          form: MedicineForm.tablet,
          scheduledAtUtc: DateTime.utc(2024, 9, 16, 8, 0),
          status: DoseStatus.missed,
        ),
        DoseOccurrence(
          id: '2',
          medicineId: 'm1',
          scheduleId: 's2',
          medicineName: 'Aspirin',
          form: MedicineForm.tablet,
          scheduledAtUtc: DateTime.utc(2024, 9, 16, 14, 0),
          status: DoseStatus.taken,
        ),
      ];

      expect(DayDoseStatus.fromDoses(doses, now: now), DayDoseStatus.hasMissed);
    });

    test('returns partialTaken when some doses are taken and some pending', () {
      final futureTime = DateTime.utc(2024, 9, 16, 14, 0);
      final doses = [
        DoseOccurrence(
          id: '1',
          medicineId: 'm1',
          scheduleId: 's1',
          medicineName: 'Aspirin',
          form: MedicineForm.tablet,
          scheduledAtUtc: DateTime.utc(2024, 9, 16, 8, 0),
          status: DoseStatus.taken,
        ),
        DoseOccurrence(
          id: '2',
          medicineId: 'm1',
          scheduleId: 's2',
          medicineName: 'Aspirin',
          form: MedicineForm.tablet,
          scheduledAtUtc: futureTime,
          status: DoseStatus.pending,
        ),
      ];

      expect(DayDoseStatus.fromDoses(doses, now: now), DayDoseStatus.partialTaken);
    });

    test('returns allSkipped when all doses are skipped', () {
      final doses = [
        DoseOccurrence(
          id: '1',
          medicineId: 'm1',
          scheduleId: 's1',
          medicineName: 'Aspirin',
          form: MedicineForm.tablet,
          scheduledAtUtc: DateTime.utc(2024, 9, 16, 8, 0),
          status: DoseStatus.skipped,
        ),
      ];

      expect(DayDoseStatus.fromDoses(doses, now: now), DayDoseStatus.allSkipped);
    });
  });

  group('DaySummary calculation', () {
    test('computes adherence rate and percentages accurately', () {
      final now = DateTime(2024, 9, 16, 12, 0);
      final date = DateTime(2024, 9, 16);
      final doses = [
        DoseOccurrence(
          id: '1',
          medicineId: 'm1',
          scheduleId: 's1',
          medicineName: 'Amoxicillin',
          form: MedicineForm.capsule,
          scheduledAtUtc: DateTime.utc(2024, 9, 16, 8, 0),
          status: DoseStatus.taken,
        ),
        DoseOccurrence(
          id: '2',
          medicineId: 'm2',
          scheduleId: 's2',
          medicineName: 'Ibuprofen',
          form: MedicineForm.tablet,
          scheduledAtUtc: DateTime.utc(2024, 9, 16, 12, 0),
          status: DoseStatus.skipped,
        ),
        DoseOccurrence(
          id: '3',
          medicineId: 'm3',
          scheduleId: 's3',
          medicineName: 'Vitamin C',
          form: MedicineForm.tablet,
          scheduledAtUtc: DateTime.utc(2024, 9, 16, 20, 0),
          status: DoseStatus.taken,
        ),
        DoseOccurrence(
          id: '4',
          medicineId: 'm4',
          scheduleId: 's4',
          medicineName: 'Paracetamol',
          form: MedicineForm.tablet,
          scheduledAtUtc: DateTime.utc(2024, 9, 16, 6, 0),
          status: DoseStatus.missed,
        ),
      ];

      final summary = DaySummary.fromDoses(date, doses, now: now);

      expect(summary.total, 4);
      expect(summary.taken, 2);
      expect(summary.skipped, 1);
      expect(summary.missed, 1);
      expect(summary.adherenceRate, 0.5);
      expect(summary.adherencePercentageString, '50%');
      expect(summary.status, DayDoseStatus.hasMissed);
    });

    test('handles zero doses gracefully', () {
      final date = DateTime(2024, 9, 16);
      final summary = DaySummary.fromDoses(date, []);

      expect(summary.total, 0);
      expect(summary.taken, 0);
      expect(summary.adherenceRate, 0.0);
      expect(summary.adherencePercentageString, '0%');
      expect(summary.status, DayDoseStatus.none);
    });
  });
}
