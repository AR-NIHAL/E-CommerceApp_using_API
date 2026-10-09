import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/entities/dose_occurrence.dart';
import 'package:flutter_application_2/features/dose_tracking/presentation/providers/dose_providers.dart';
import 'package:flutter_application_2/features/medicines/presentation/providers/medicine_providers.dart';
import '../../domain/entities/history_models.dart';

/// Currently selected view mode (Daily | Weekly | Monthly).
final historyViewModeProvider = StateProvider<HistoryViewMode>((ref) {
  return HistoryViewMode.monthly;
});

/// Month currently displayed in the calendar (normalized to day 1).
final historyCurrentMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

/// Specific date selected by the user to inspect doses (normalized to midnight).
final historySelectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// Fetches all doses for a given month.
final monthlyDosesProvider =
    FutureProvider.family<List<DoseOccurrence>, DateTime>((ref, month) async {
  final startOfMonth = DateTime(month.year, month.month, 1, 0, 0, 0);
  final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59, 999);

  final useCase = ref.watch(getDosesByDateRangeUseCaseProvider);
  return await useCase.execute(startOfMonth, endOfMonth);
});

/// Map of day numbers (1..31) in the current month to their [DayDoseStatus].
final monthDayStatusMapProvider = Provider<Map<int, DayDoseStatus>>((ref) {
  final currentMonth = ref.watch(historyCurrentMonthProvider);
  final monthlyDosesAsync = ref.watch(monthlyDosesProvider(currentMonth));

  final doses = monthlyDosesAsync.valueOrNull ?? [];
  final map = <int, DayDoseStatus>{};

  // Group doses by day of month in local time
  final dosesByDay = <int, List<DoseOccurrence>>{};
  for (final dose in doses) {
    final local = dose.scheduledAtLocal;
    if (local.year == currentMonth.year && local.month == currentMonth.month) {
      dosesByDay.putIfAbsent(local.day, () => []).add(dose);
    }
  }

  for (final entry in dosesByDay.entries) {
    map[entry.key] = DayDoseStatus.fromDoses(entry.value);
  }

  return map;
});

/// Doses scheduled for the currently selected date.
final selectedDateDosesProvider = Provider<List<DoseOccurrence>>((ref) {
  final selectedDate = ref.watch(historySelectedDateProvider);
  final month = DateTime(selectedDate.year, selectedDate.month, 1);
  final monthlyDosesAsync = ref.watch(monthlyDosesProvider(month));

  final allDoses = monthlyDosesAsync.valueOrNull ?? [];
  return allDoses.where((d) {
    final local = d.scheduledAtLocal;
    return local.year == selectedDate.year &&
        local.month == selectedDate.month &&
        local.day == selectedDate.day;
  }).toList();
});

/// Adherence summary for the currently selected date.
final selectedDateSummaryProvider = Provider<DaySummary>((ref) {
  final selectedDate = ref.watch(historySelectedDateProvider);
  final doses = ref.watch(selectedDateDosesProvider);
  return DaySummary.fromDoses(selectedDate, doses);
});

/// Weekly adherence data for the current week containing the selected date.
final weekSummariesProvider = Provider<List<DaySummary>>((ref) {
  final selectedDate = ref.watch(historySelectedDateProvider);
  // Start of week: Monday
  final monday = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
  final month = DateTime(monday.year, monday.month, 1);
  final dosesAsync = ref.watch(monthlyDosesProvider(month));
  final doses = dosesAsync.valueOrNull ?? [];

  final days = <DaySummary>[];
  for (int i = 0; i < 7; i++) {
    final dayDate = DateTime(monday.year, monday.month, monday.day + i);
    final dayDoses = doses.where((d) {
      final local = d.scheduledAtLocal;
      return local.year == dayDate.year &&
          local.month == dayDate.month &&
          local.day == dayDate.day;
    }).toList();

    days.add(DaySummary.fromDoses(dayDate, dayDoses));
  }

  return days;
});

/// Actions controller for the History screen.
class HistoryController {
  final Ref _ref;

  const HistoryController(this._ref);

  void selectDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    _ref.read(historySelectedDateProvider.notifier).state = normalized;

    // Ensure the current month is in sync if date is outside view
    final currentMonth = _ref.read(historyCurrentMonthProvider);
    if (normalized.year != currentMonth.year || normalized.month != currentMonth.month) {
      _ref.read(historyCurrentMonthProvider.notifier).state =
          DateTime(normalized.year, normalized.month, 1);
    }
  }

  void nextMonth() {
    final current = _ref.read(historyCurrentMonthProvider);
    _ref.read(historyCurrentMonthProvider.notifier).state =
        DateTime(current.year, current.month + 1, 1);
  }

  void previousMonth() {
    final current = _ref.read(historyCurrentMonthProvider);
    _ref.read(historyCurrentMonthProvider.notifier).state =
        DateTime(current.year, current.month - 1, 1);
  }

  void setViewMode(HistoryViewMode mode) {
    _ref.read(historyViewModeProvider.notifier).state = mode;
  }

  Future<void> markTaken(String occurrenceId) async {
    await _ref.read(markDoseTakenUseCaseProvider).execute(occurrenceId);
    _ref.invalidate(monthlyDosesProvider);
    _ref.invalidate(todayDosesProvider);
    _ref.invalidate(medicinesListProvider);
  }

  Future<void> skipDose(String occurrenceId) async {
    await _ref.read(skipDoseUseCaseProvider).execute(occurrenceId);
    _ref.invalidate(monthlyDosesProvider);
    _ref.invalidate(todayDosesProvider);
    _ref.invalidate(medicinesListProvider);
  }

  Future<void> refresh() async {
    _ref.invalidate(monthlyDosesProvider);
  }
}

final historyControllerProvider = Provider<HistoryController>((ref) {
  return HistoryController(ref);
});
