import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../dose_tracking/domain/entities/dose_occurrence.dart';

class DoseScheduleCard extends StatelessWidget {
  final DoseOccurrence dose;
  final VoidCallback? onTap;

  const DoseScheduleCard({
    super.key,
    required this.dose,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final effectiveStatus = dose.effectiveStatus(now);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Medicine Pill Icon Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _avatarColor(effectiveStatus),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    color: _iconColor(effectiveStatus),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                // Title and details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dose.strength != null
                            ? '${dose.medicineName} ${dose.strength}'
                            : dose.medicineName,
                        style: AppTypography.titleSmall.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${dose.plannedQuantity.toInt()} ${dose.doseUnit}'
                        '${dose.instruction != null ? ' · ${dose.instruction}' : ''}',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Time & Status indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      dose.formattedTime,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildStatusIcon(effectiveStatus),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(DoseStatus status) {
    switch (status) {
      case DoseStatus.taken:
        return Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
        );
      case DoseStatus.skipped:
        return Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.warning,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
        );
      case DoseStatus.missed:
        return Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.danger,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.priority_high_rounded, color: Colors.white, size: 14),
        );
      case DoseStatus.pending:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 1.8),
          ),
        );
    }
  }

  Color _avatarColor(DoseStatus status) {
    switch (status) {
      case DoseStatus.taken:
        return AppColors.primaryLight;
      case DoseStatus.skipped:
        return AppColors.warningLight;
      case DoseStatus.missed:
        return AppColors.dangerLight;
      case DoseStatus.pending:
        return AppColors.primaryLight;
    }
  }

  Color _iconColor(DoseStatus status) {
    switch (status) {
      case DoseStatus.taken:
        return AppColors.primary;
      case DoseStatus.skipped:
        return AppColors.warning;
      case DoseStatus.missed:
        return AppColors.danger;
      case DoseStatus.pending:
        return AppColors.primary;
    }
  }
}
