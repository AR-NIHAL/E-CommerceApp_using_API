import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/history_providers.dart';

class HistoryWeeklyView extends ConsumerWidget {
  const HistoryWeeklyView({super.key});

  static const _weekdaysShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(weekSummariesProvider);
    final selectedDate = ref.watch(historySelectedDateProvider);

    return Column(
      children: summaries.map((summary) {
        final date = summary.date;
        final isSelected = selectedDate.year == date.year &&
            selectedDate.month == date.month &&
            selectedDate.day == date.day;
        final dayLabel = _weekdaysShort[date.weekday - 1];
        final monthLabel = _monthsShort[date.month - 1];
        final hasDoses = summary.total > 0;
        final percent = (summary.adherenceRate * 100).round();

        return GestureDetector(
          onTap: () {
            ref.read(historyControllerProvider).selectDate(date);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.8 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Day circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                      ),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Info & progress
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$dayLabel, ${date.day} $monthLabel',
                            style: AppTypography.titleSmall.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            hasDoses ? '$percent% Taken' : 'No schedule',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: hasDoses
                                  ? (percent >= 80 ? AppColors.primary : AppColors.warning)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: hasDoses ? summary.adherenceRate : 0.0,
                          backgroundColor: AppColors.background,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            percent >= 80 ? AppColors.primary : AppColors.warning,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Status chip / count
                if (hasDoses) ...[
                  Text(
                    '${summary.taken}/${summary.total}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                ] else ...[
                  const Icon(Icons.remove_rounded, size: 16, color: AppColors.textSecondary),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
