import 'package:flutter_application_2/features/dose_tracking/domain/entities/dose_occurrence.dart';

/// Supported view modes for the history screen.
enum HistoryViewMode {
  daily,
  weekly,
  monthly;

  String get label {
    switch (this) {
      case HistoryViewMode.daily:
        return 'Daily';
      case HistoryViewMode.weekly:
        return 'Weekly';
      case HistoryViewMode.monthly:
        return 'Monthly';
    }
  }
}

/// Overall status for a specific day in the calendar.
enum DayDoseStatus {
  none,
  allTaken,
  partialTaken,
  hasMissed,
  allSkipped,
  futurePending;

  /// Helper to derive status from a list of doses on a day.
  static DayDoseStatus fromDoses(List<DoseOccurrence> doses, {DateTime? now}) {
    if (doses.isEmpty) return DayDoseStatus.none;

    final currentTime = now ?? DateTime.now();
    int taken = 0;
    int skipped = 0;
    int missed = 0;
    int pending = 0;

    for (final d in doses) {
      final effStatus = d.effectiveStatus(currentTime);
      switch (effStatus) {
        case DoseStatus.taken:
          taken++;
          break;
        case DoseStatus.skipped:
          skipped++;
          break;
        case DoseStatus.missed:
          missed++;
          break;
        case DoseStatus.pending:
          pending++;
          break;
      }
    }

    if (missed > 0) return DayDoseStatus.hasMissed;
    if (taken == doses.length) return DayDoseStatus.allTaken;
    if (skipped == doses.length) return DayDoseStatus.allSkipped;
    if (pending == doses.length && doses.first.scheduledAtLocal.isAfter(currentTime)) {
      return DayDoseStatus.futurePending;
    }
    if (taken > 0) return DayDoseStatus.partialTaken;

    return DayDoseStatus.none;
  }
}

/// Aggregated adherence summary for a specific calendar date.
class DaySummary {
  final DateTime date;
  final int total;
  final int taken;
  final int skipped;
  final int missed;
  final int pending;
  final DayDoseStatus status;

  const DaySummary({
    required this.date,
    required this.total,
    required this.taken,
    required this.skipped,
    required this.missed,
    required this.pending,
    required this.status,
  });

  /// Adherence rate between 0.0 and 1.0.
  double get adherenceRate => total == 0 ? 0.0 : (taken / total);

  /// Percentage integer string, e.g. "80%".
  String get adherencePercentageString => '${(adherenceRate * 100).round()}%';

  factory DaySummary.fromDoses(DateTime date, List<DoseOccurrence> doses, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    int taken = 0;
    int skipped = 0;
    int missed = 0;
    int pending = 0;

    for (final d in doses) {
      final effStatus = d.effectiveStatus(currentTime);
      switch (effStatus) {
        case DoseStatus.taken:
          taken++;
          break;
        case DoseStatus.skipped:
          skipped++;
          break;
        case DoseStatus.missed:
          missed++;
          break;
        case DoseStatus.pending:
          pending++;
          break;
      }
    }

    final status = DayDoseStatus.fromDoses(doses, now: currentTime);

    return DaySummary(
      date: date,
      total: doses.length,
      taken: taken,
      skipped: skipped,
      missed: missed,
      pending: pending,
      status: status,
    );
  }
}
