import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/stats_models.dart';

class AdherenceGaugeCard extends StatelessWidget {
  final OverallStats stats;

  const AdherenceGaugeCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (stats.overallAdherenceRate * 100).round();

    Color gaugeColor;
    if (percent >= 80) {
      gaugeColor = AppColors.primary;
    } else if (percent >= 50) {
      gaugeColor = AppColors.warning;
    } else {
      gaugeColor = AppColors.danger;
    }

    return Container(
      padding: const EdgeInsets.all(22),
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
          // Circular Adherence Gauge
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Track
                SizedBox(
                  width: 130,
                  height: 130,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryLight.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                // Progress Arc
                SizedBox(
                  width: 130,
                  height: 130,
                  child: CircularProgressIndicator(
                    value: stats.totalDoses == 0 ? 0.0 : stats.overallAdherenceRate,
                    strokeWidth: 12,
                    strokeCap: StrokeCap.round,
                    valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
                  ),
                ),
                // Percentage Text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percent%',
                      style: AppTypography.displayMedium.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    const Text(
                      'Adherence',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Grade Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: gaugeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              stats.adherenceGrade,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: gaugeColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),

          // 4 Metrics Grid/Row
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  count: '${stats.totalDoses}',
                  label: 'Scheduled',
                  color: AppColors.navy,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  count: '${stats.takenDoses}',
                  label: 'Taken',
                  color: AppColors.success,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  count: '${stats.skippedDoses}',
                  label: 'Skipped',
                  color: AppColors.warning,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  count: '${stats.missedDoses}',
                  label: 'Missed',
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String count,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
