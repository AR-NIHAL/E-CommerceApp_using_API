import 'package:flutter_application_2/features/medicines/domain/entities/medicine.dart';
import 'package:flutter_application_2/features/medicines/domain/entities/medicine_schedule.dart';
import '../entities/dose_occurrence.dart';

/// Pure domain service responsible for generating daily dose occurrences from medicine schedules.
class DoseOccurrenceGenerator {
  const DoseOccurrenceGenerator();

  /// Generates a list of [DoseOccurrence] for a given [medicine] and its [schedules]
  /// between [from] and [until] (inclusive).
  List<DoseOccurrence> generate({
    required Medicine medicine,
    required List<MedicineSchedule> schedules,
    required DateTime from,
    required DateTime until,
  }) {
    if (!medicine.isActive || schedules.isEmpty) {
      return [];
    }

    final occurrences = <DoseOccurrence>[];

    // Normalize from and until to date only (00:00:00)
    final fromDate = DateTime(from.year, from.month, from.day);
    final untilDate = DateTime(until.year, until.month, until.day);

    final medStartDate = DateTime(
      medicine.startDate.year,
      medicine.startDate.month,
      medicine.startDate.day,
    );

    final medEndDate = medicine.endDate != null
        ? DateTime(medicine.endDate!.year, medicine.endDate!.month, medicine.endDate!.day)
        : null;

    var currentDay = fromDate;
    while (!currentDay.isAfter(untilDate)) {
      // Check if current day is within medicine active date range
      if (currentDay.isBefore(medStartDate)) {
        currentDay = currentDay.add(const Duration(days: 1));
        continue;
      }
      if (medEndDate != null && currentDay.isAfter(medEndDate)) {
        break; // Passed end date
      }

      final weekday = currentDay.weekday; // 1 = Monday, 7 = Sunday

      for (final schedule in schedules) {
        if (!schedule.reminderEnabled) continue;
        if (!schedule.weekDays.contains(weekday)) continue;

        final scheduledLocal = DateTime(
          currentDay.year,
          currentDay.month,
          currentDay.day,
          schedule.hour,
          schedule.minute,
        );

        final scheduledUtc = scheduledLocal.toUtc();

        // Idempotent deterministic ID
        final dateKey = '${currentDay.year}'
            '-${currentDay.month.toString().padLeft(2, '0')}'
            '-${currentDay.day.toString().padLeft(2, '0')}';
        final timeKey = '${schedule.hour.toString().padLeft(2, '0')}'
            '${schedule.minute.toString().padLeft(2, '0')}';
        final occurrenceId = 'occ_${schedule.id}_${dateKey}_$timeKey';

        occurrences.add(
          DoseOccurrence(
            id: occurrenceId,
            medicineId: medicine.id,
            scheduleId: schedule.id,
            medicineName: medicine.name,
            strength: medicine.strength,
            form: medicine.form,
            instruction: schedule.instruction,
            scheduledAtUtc: scheduledUtc,
            status: DoseStatus.pending,
            plannedQuantity: schedule.doseQuantity,
            doseUnit: schedule.doseUnit,
          ),
        );
      }

      currentDay = currentDay.add(const Duration(days: 1));
    }

    return occurrences;
  }
}
