import 'package:flutter_application_2/features/medicines/domain/entities/medicine.dart';

/// Available timeframes for adherence statistics.
enum StatsTimeframe {
  weekly,
  monthly,
  allTime;

  String get label {
    switch (this) {
      case StatsTimeframe.weekly:
        return 'Weekly';
      case StatsTimeframe.monthly:
        return 'Monthly';
      case StatsTimeframe.allTime:
        return 'All Time';
    }
  }
}

/// A single day's data point for the adherence bar chart.
class DayChartPoint {
  final DateTime date;
  final String dayLabel; // e.g. "Mon", "Tue"
  final int total;
  final int taken;

  const DayChartPoint({
    required this.date,
    required this.dayLabel,
    required this.total,
    required this.taken,
  });

  /// Adherence percentage between 0.0 and 100.0
  double get adherencePercent =>
      total == 0 ? 0.0 : ((taken / total) * 100).clamp(0.0, 100.0);
}

/// Adherence statistics for a specific medicine.
class MedicineAdherence {
  final String medicineId;
  final String medicineName;
  final String? strength;
  final MedicineForm form;
  final int totalDoses;
  final int takenDoses;
  final int skippedDoses;
  final int missedDoses;

  const MedicineAdherence({
    required this.medicineId,
    required this.medicineName,
    this.strength,
    required this.form,
    required this.totalDoses,
    required this.takenDoses,
    required this.skippedDoses,
    required this.missedDoses,
  });

  /// Adherence rate between 0.0 and 1.0
  double get adherenceRate =>
      totalDoses == 0 ? 0.0 : (takenDoses / totalDoses).clamp(0.0, 1.0);

  String get adherencePercentageString =>
      '${(adherenceRate * 100).round()}%';
}

/// Streak statistics for consecutive days of full adherence.
class StreakStats {
  final int currentStreak;
  final int bestStreak;

  const StreakStats({
    required this.currentStreak,
    required this.bestStreak,
  });

  static const zero = StreakStats(currentStreak: 0, bestStreak: 0);
}

/// Complete aggregated statistics for a timeframe.
class OverallStats {
  final StatsTimeframe timeframe;
  final int totalDoses;
  final int takenDoses;
  final int skippedDoses;
  final int missedDoses;
  final int pendingDoses;
  final double overallAdherenceRate;
  final List<DayChartPoint> chartPoints;
  final List<MedicineAdherence> medicineBreakdown;
  final StreakStats streaks;

  const OverallStats({
    required this.timeframe,
    required this.totalDoses,
    required this.takenDoses,
    required this.skippedDoses,
    required this.missedDoses,
    required this.pendingDoses,
    required this.overallAdherenceRate,
    required this.chartPoints,
    required this.medicineBreakdown,
    required this.streaks,
  });

  String get adherencePercentageString =>
      '${(overallAdherenceRate * 100).round()}%';

  String get adherenceGrade {
    final percent = (overallAdherenceRate * 100).round();
    if (percent >= 90) return 'Excellent Adherence! 🎉';
    if (percent >= 75) return 'Good Progress! Keep going 💪';
    if (percent >= 50) return 'Needs Attention ⚠️';
    return 'Action Needed 🩺';
  }

  static const empty = OverallStats(
    timeframe: StatsTimeframe.weekly,
    totalDoses: 0,
    takenDoses: 0,
    skippedDoses: 0,
    missedDoses: 0,
    pendingDoses: 0,
    overallAdherenceRate: 0.0,
    chartPoints: [],
    medicineBreakdown: [],
    streaks: StreakStats.zero,
  );
}
