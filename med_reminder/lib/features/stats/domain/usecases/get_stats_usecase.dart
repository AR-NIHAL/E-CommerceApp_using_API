import 'package:flutter_application_2/features/dose_tracking/domain/entities/dose_occurrence.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/repositories/dose_repository.dart';
import 'package:flutter_application_2/features/medicines/domain/entities/medicine.dart';
import 'package:flutter_application_2/features/medicines/domain/repositories/medicine_repository.dart';
import '../entities/stats_models.dart';

class GetStatsUseCase {
  final DoseRepository doseRepository;
  final MedicineRepository medicineRepository;

  const GetStatsUseCase({
    required this.doseRepository,
    required this.medicineRepository,
  });

  static const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Future<OverallStats> execute({
    StatsTimeframe timeframe = StatsTimeframe.weekly,
    DateTime? now,
  }) async {
    final currentTime = now ?? DateTime.now();
    final allDoses = await doseRepository.getAllDoses();
    final medicines = await medicineRepository.getMedicines();

    final dosesInTimeframe = _filterDosesByTimeframe(allDoses, timeframe, currentTime);

    // Calculate dose status counts
    int taken = 0;
    int skipped = 0;
    int missed = 0;
    int pending = 0;

    for (final dose in dosesInTimeframe) {
      final eff = dose.effectiveStatus(currentTime);
      switch (eff) {
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

    final total = dosesInTimeframe.length;
    final completed = taken + skipped + missed;
    final overallAdherence = completed > 0
        ? (taken / completed).clamp(0.0, 1.0)
        : (total > 0 ? (taken / total).clamp(0.0, 1.0) : 0.0);

    // Chart points
    final chartPoints = _buildChartPoints(allDoses, dosesInTimeframe, timeframe, currentTime);

    // Per-medicine breakdown
    final medicineBreakdown = _buildMedicineBreakdown(medicines, dosesInTimeframe, currentTime);

    // Streaks
    final streaks = _calculateStreaks(allDoses, currentTime);

    return OverallStats(
      timeframe: timeframe,
      totalDoses: total,
      takenDoses: taken,
      skippedDoses: skipped,
      missedDoses: missed,
      pendingDoses: pending,
      overallAdherenceRate: overallAdherence,
      chartPoints: chartPoints,
      medicineBreakdown: medicineBreakdown,
      streaks: streaks,
    );
  }

  List<DoseOccurrence> _filterDosesByTimeframe(
    List<DoseOccurrence> doses,
    StatsTimeframe timeframe,
    DateTime now,
  ) {
    switch (timeframe) {
      case StatsTimeframe.weekly:
        final monday = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        final sunday = monday.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return doses.where((d) {
          final local = d.scheduledAtLocal;
          return !local.isBefore(monday) && !local.isAfter(sunday);
        }).toList();

      case StatsTimeframe.monthly:
        final startOfMonth = DateTime(now.year, now.month, 1, 0, 0, 0);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return doses.where((d) {
          final local = d.scheduledAtLocal;
          return !local.isBefore(startOfMonth) && !local.isAfter(endOfMonth);
        }).toList();

      case StatsTimeframe.allTime:
        return doses;
    }
  }

  List<DayChartPoint> _buildChartPoints(
    List<DoseOccurrence> allDoses,
    List<DoseOccurrence> filteredDoses,
    StatsTimeframe timeframe,
    DateTime now,
  ) {
    if (timeframe == StatsTimeframe.weekly) {
      final monday = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      final points = <DayChartPoint>[];

      for (int i = 0; i < 7; i++) {
        final day = monday.add(Duration(days: i));
        final dayDoses = filteredDoses.where((d) {
          final local = d.scheduledAtLocal;
          return local.year == day.year && local.month == day.month && local.day == day.day;
        }).toList();

        final dayTaken = dayDoses.where((d) => d.effectiveStatus(now) == DoseStatus.taken).length;
        points.add(
          DayChartPoint(
            date: day,
            dayLabel: _weekdayLabels[i],
            total: dayDoses.length,
            taken: dayTaken,
          ),
        );
      }
      return points;
    } else if (timeframe == StatsTimeframe.monthly) {
      // 4 week intervals of current month
      final points = <DayChartPoint>[];
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final bucketSize = (daysInMonth / 4).ceil();

      for (int i = 0; i < 4; i++) {
        final startDay = i * bucketSize + 1;
        final endDay = ((i + 1) * bucketSize).clamp(1, daysInMonth);
        final startDate = DateTime(now.year, now.month, startDay);
        final endDate = DateTime(now.year, now.month, endDay, 23, 59, 59);

        final bucketDoses = filteredDoses.where((d) {
          final local = d.scheduledAtLocal;
          return !local.isBefore(startDate) && !local.isAfter(endDate);
        }).toList();

        final bucketTaken = bucketDoses.where((d) => d.effectiveStatus(now) == DoseStatus.taken).length;
        points.add(
          DayChartPoint(
            date: startDate,
            dayLabel: 'W${i + 1}',
            total: bucketDoses.length,
            taken: bucketTaken,
          ),
        );
      }
      return points;
    } else {
      // All time: last 7 days leading up to today
      final points = <DayChartPoint>[];
      final today = DateTime(now.year, now.month, now.day);
      for (int i = 6; i >= 0; i--) {
        final day = today.subtract(Duration(days: i));
        final dayDoses = allDoses.where((d) {
          final local = d.scheduledAtLocal;
          return local.year == day.year && local.month == day.month && local.day == day.day;
        }).toList();

        final dayTaken = dayDoses.where((d) => d.effectiveStatus(now) == DoseStatus.taken).length;
        points.add(
          DayChartPoint(
            date: day,
            dayLabel: _weekdayLabels[day.weekday - 1],
            total: dayDoses.length,
            taken: dayTaken,
          ),
        );
      }
      return points;
    }
  }

  List<MedicineAdherence> _buildMedicineBreakdown(
    List<Medicine> medicines,
    List<DoseOccurrence> doses,
    DateTime now,
  ) {
    final breakdown = <MedicineAdherence>[];

    // Group doses by medicineId
    final groupedDoses = <String, List<DoseOccurrence>>{};
    for (final d in doses) {
      groupedDoses.putIfAbsent(d.medicineId, () => []).add(d);
    }

    // Include all active medicines or medicines with doses
    for (final med in medicines) {
      final medDoses = groupedDoses[med.id] ?? [];
      int mTaken = 0;
      int mSkipped = 0;
      int mMissed = 0;

      for (final d in medDoses) {
        final eff = d.effectiveStatus(now);
        switch (eff) {
          case DoseStatus.taken:
            mTaken++;
            break;
          case DoseStatus.skipped:
            mSkipped++;
            break;
          case DoseStatus.missed:
            mMissed++;
            break;
          case DoseStatus.pending:
            break;
        }
      }

      breakdown.add(
        MedicineAdherence(
          medicineId: med.id,
          medicineName: med.name,
          strength: med.strength,
          form: med.form,
          totalDoses: medDoses.length,
          takenDoses: mTaken,
          skippedDoses: mSkipped,
          missedDoses: mMissed,
        ),
      );
    }

    // Sort: highest total doses first, then highest adherence rate
    breakdown.sort((a, b) {
      final cmp = b.totalDoses.compareTo(a.totalDoses);
      if (cmp != 0) return cmp;
      return b.adherenceRate.compareTo(a.adherenceRate);
    });

    return breakdown;
  }

  StreakStats _calculateStreaks(List<DoseOccurrence> allDoses, DateTime now) {
    if (allDoses.isEmpty) return StreakStats.zero;

    // Group doses by date (local yyyy-mm-dd)
    final dosesByDay = <String, List<DoseOccurrence>>{};
    for (final d in allDoses) {
      final local = d.scheduledAtLocal;
      final key = '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
      dosesByDay.putIfAbsent(key, () => []).add(d);
    }

    final sortedDates = dosesByDay.keys.toList()..sort();
    if (sortedDates.isEmpty) return StreakStats.zero;

    int currentStreak = 0;
    int bestStreak = 0;
    int runningStreak = 0;

    for (final dateKey in sortedDates) {
      final dayDoses = dosesByDay[dateKey]!;
      int taken = 0;
      int missed = 0;

      for (final d in dayDoses) {
        final eff = d.effectiveStatus(now);
        if (eff == DoseStatus.taken) taken++;
        if (eff == DoseStatus.missed) missed++;
      }

      if (taken > 0 && taken == dayDoses.length) {
        runningStreak++;
        if (runningStreak > bestStreak) bestStreak = runningStreak;
      } else if (missed > 0) {
        runningStreak = 0;
      }
    }

    currentStreak = runningStreak;
    return StreakStats(
      currentStreak: currentStreak,
      bestStreak: bestStreak,
    );
  }
}
