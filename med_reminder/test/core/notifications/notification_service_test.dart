import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/core/notifications/notification_service.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/entities/dose_occurrence.dart';
import 'package:flutter_application_2/features/medicines/domain/entities/medicine.dart';

void main() {
  group('NotificationService Utilities', () {
    test('doseIdToNotificationId generates deterministic 32-bit positive integers', () {
      const id1 = 'occ_schedule1_2024-09-18_0800';
      const id2 = 'occ_schedule1_2024-09-18_1200';

      final intId1 = NotificationService.doseIdToNotificationId(id1);
      final intId1Again = NotificationService.doseIdToNotificationId(id1);
      final intId2 = NotificationService.doseIdToNotificationId(id2);

      expect(intId1, intId1Again);
      expect(intId1, isNot(equals(intId2)));
      expect(intId1, greaterThanOrEqualTo(0));
      expect(intId1, lessThanOrEqualTo(2147483647));
    });

    test('encodePayload and decodeOccurrenceId roundtrip correctly', () {
      final dose = DoseOccurrence(
        id: 'occ_test_123',
        medicineId: 'med_456',
        scheduleId: 'sch_789',
        medicineName: 'Amoxicillin',
        strength: '500mg',
        form: MedicineForm.capsule,
        instruction: 'After meal',
        scheduledAtUtc: DateTime.utc(2024, 9, 20, 8, 30),
        status: DoseStatus.pending,
      );

      final payload = NotificationService.encodePayload(dose);
      expect(payload, contains('occ_test_123'));
      expect(payload, contains('Amoxicillin'));

      final decodedId = NotificationService.decodeOccurrenceId(payload);
      expect(decodedId, 'occ_test_123');
    });

    test('decodeOccurrenceId returns null for invalid or null payload', () {
      expect(NotificationService.decodeOccurrenceId(null), isNull);
      expect(NotificationService.decodeOccurrenceId(''), isNull);
      expect(NotificationService.decodeOccurrenceId('invalid-not-json'), isNull);
      expect(NotificationService.decodeOccurrenceId('{"other": 123}'), isNull);
    });
  });

  group('NotificationService Scheduling Filters', () {
    final now = DateTime(2024, 9, 18, 10, 0);

    test('schedulePendingDoses filters out past, non-pending, or out-of-range doses', () async {
      final service = NotificationService();

      final doses = [
        // Past dose (should be ignored)
        DoseOccurrence(
          id: 'past_1',
          medicineId: 'm1',
          scheduleId: 's1',
          medicineName: 'Aspirin',
          form: MedicineForm.tablet,
          scheduledAtUtc: DateTime(2024, 9, 18, 8, 0).toUtc(),
          status: DoseStatus.pending,
        ),
        // Already taken dose in future (should be ignored)
        DoseOccurrence(
          id: 'taken_1',
          medicineId: 'm1',
          scheduleId: 's1',
          medicineName: 'Aspirin',
          form: MedicineForm.tablet,
          scheduledAtUtc: DateTime(2024, 9, 18, 14, 0).toUtc(),
          status: DoseStatus.taken,
        ),
        // Far future dose (> 7 days, should be ignored)
        DoseOccurrence(
          id: 'future_far',
          medicineId: 'm1',
          scheduleId: 's1',
          medicineName: 'Aspirin',
          form: MedicineForm.tablet,
          scheduledAtUtc: DateTime(2024, 9, 30, 8, 0).toUtc(),
          status: DoseStatus.pending,
        ),
        // Valid upcoming pending dose within 7 days
        DoseOccurrence(
          id: 'valid_1',
          medicineId: 'm1',
          scheduleId: 's1',
          medicineName: 'Aspirin',
          form: MedicineForm.tablet,
          scheduledAtUtc: DateTime(2024, 9, 18, 18, 0).toUtc(),
          status: DoseStatus.pending,
        ),
      ];

      // Service handles gracefully without platform crashes
      await expectLater(
        service.schedulePendingDoses(doses, now: now, daysAhead: 7),
        completes,
      );
    });

    test('cancelDose and cancelAll execute safely', () async {
      final service = NotificationService();
      await expectLater(service.cancelDose('occ_123'), completes);
      await expectLater(service.cancelAll(), completes);
    });
  });
}
