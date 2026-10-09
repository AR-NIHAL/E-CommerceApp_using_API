import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/history_models.dart';
import '../providers/history_providers.dart';

class HistoryCalendarCard extends ConsumerWidget {
  const HistoryCalendarCard({super.key});

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static const _weekdayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMonth = ref.watch(historyCurrentMonthProvider);
    final selectedDate = ref.watch(historySelectedDateProvider);
    final statusMap = ref.watch(monthDayStatusMapProvider);
    final now = DateTime.now();

    final totalDays = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final firstWeekday = DateTime(currentMonth.year, currentMonth.month, 1).weekday % 7; // Sunday = 0
    final totalCells = firstWeekday + totalDays;
    final totalRows = (totalCells / 7).ceil();

    final monthTitle = '${_monthNames[currentMonth.month - 1]} ${currentMonth.year}';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month navigation header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, color: AppColors.navy),
                onPressed: () => ref.read(historyControllerProvider).previousMonth(),
                tooltip: 'Previous Month',
              ),
              Text(
                monthTitle,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, color: AppColors.navy),
                onPressed: () => ref.read(historyControllerProvider).nextMonth(),
                tooltip: 'Next Month',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weekday header row
          Row(
            children: _weekdayLabels.map((label) {
              return Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Calendar days grid
          Column(
            children: List.generate(totalRows, (row) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: List.generate(7, (col) {
                    final cellIndex = row * 7 + col;
                    if (cellIndex < firstWeekday || cellIndex >= totalCells) {
                      return const Expanded(child: SizedBox(height: 44));
                    }

                    final dayNumber = cellIndex - firstWeekday + 1;
                    final cellDate = DateTime(currentMonth.year, currentMonth.month, dayNumber);
                    final isSelected = selectedDate.year == cellDate.year &&
                        selectedDate.month == cellDate.month &&
                        selectedDate.day == cellDate.day;
                    final isToday = now.year == cellDate.year &&
                        now.month == cellDate.month &&
                        now.day == cellDate.day;

                    final dayStatus = statusMap[dayNumber] ?? DayDoseStatus.none;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ref.read(historyControllerProvider).selectDate(cellDate);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            shape: BoxShape.circle,
                            border: isToday && !isSelected
                                ? Border.all(color: AppColors.primary, width: 1.5)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$dayNumber',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected || isToday
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : isToday
                                          ? AppColors.primary
                                          : AppColors.navy,
                                ),
                              ),
                              const SizedBox(height: 2),
                              _buildStatusDot(dayStatus, isSelected),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 10),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(AppColors.success, 'Taken'),
              const SizedBox(width: 14),
              _buildLegendItem(AppColors.warning, 'Partial/Skip'),
              const SizedBox(width: 14),
              _buildLegendItem(AppColors.danger, 'Missed'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot(DayDoseStatus status, bool isSelected) {
    if (status == DayDoseStatus.none) {
      return const SizedBox(height: 4);
    }

    Color color;
    switch (status) {
      case DayDoseStatus.allTaken:
        color = isSelected ? Colors.white : AppColors.success;
        break;
      case DayDoseStatus.hasMissed:
        color = isSelected ? const Color(0xFFFFB4B4) : AppColors.danger;
        break;
      case DayDoseStatus.partialTaken:
      case DayDoseStatus.allSkipped:
        color = isSelected ? const Color(0xFFFFE0A3) : AppColors.warning;
        break;
      case DayDoseStatus.futurePending:
        color = isSelected ? Colors.white.withValues(alpha: 0.6) : const Color(0xFFCBD5E1);
        break;
      case DayDoseStatus.none:
        color = Colors.transparent;
        break;
    }

    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
