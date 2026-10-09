import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/history_providers.dart';

class HistorySummaryCard extends ConsumerWidget {
  const HistorySummaryCard({super.key});

  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  static const _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(selectedDateSummaryProvider);
    final date = summary.date;

    final weekdayName = _weekdays[date.weekday - 1];
    final monthShort = _monthsShort[date.month - 1];
    final dateString = '$weekdayName, ${date.day} $monthShort ${date.year}';

    final hasDoses = summary.total > 0;
    final adherencePercent = (summary.adherenceRate * 100).round();

    Color adherenceBadgeBg;
    Color adherenceBadgeText;
    if (!hasDoses) {
      adherenceBadgeBg = AppColors.background;
      adherenceBadgeText = AppColors.textSecondary;
    } else if (adherencePercent >= 80) {
      adherenceBadgeBg = AppColors.primaryLight;
      adherenceBadgeText = AppColors.primary;
    } else if (adherencePercent >= 50) {
      adherenceBadgeBg = const Color(0xFFFEF3C7);
      adherenceBadgeText = const Color(0xFFD97706);
    } else {
      adherenceBadgeBg = AppColors.dangerLight;
      adherenceBadgeText = AppColors.danger;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: Date and Adherence Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateString,
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: adherenceBadgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hasDoses ? '$adherencePercent% Adherence' : 'No Doses',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: adherenceBadgeText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Linear progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: hasDoses ? summary.adherenceRate : 0.0,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(
                adherencePercent >= 80 ? AppColors.primary : AppColors.warning,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 14),

          // Counter Pills Row
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                  bgColor: AppColors.primaryLight,
                  count: summary.taken,
                  label: 'Taken',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.skip_next_rounded,
                  color: AppColors.warning,
                  bgColor: const Color(0xFFFEF3C7),
                  count: summary.skipped,
                  label: 'Skipped',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.cancel_rounded,
                  color: AppColors.danger,
                  bgColor: AppColors.dangerLight,
                  count: summary.missed,
                  label: 'Missed',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required int count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
