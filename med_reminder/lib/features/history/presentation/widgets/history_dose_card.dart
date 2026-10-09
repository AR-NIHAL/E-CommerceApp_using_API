import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../dose_tracking/domain/entities/dose_occurrence.dart';
import '../../../medicines/domain/entities/medicine.dart';
import '../providers/history_providers.dart';

class HistoryDoseCard extends ConsumerWidget {
  final DoseOccurrence dose;

  const HistoryDoseCard({
    super.key,
    required this.dose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final effective = dose.effectiveStatus(now);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Medicine Form Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _iconBgColor(effective),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _formIcon(dose.form),
              color: _iconColor(effective),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Medicine Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dose.strength != null
                            ? '${dose.medicineName} ${dose.strength}'
                            : dose.medicineName,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      dose.formattedTime,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•  ${dose.plannedQuantity.toInt()} ${dose.doseUnit}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Status Badge / Action Button
          _buildStatusBadge(context, ref, effective),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, WidgetRef ref, DoseStatus status) {
    switch (status) {
      case DoseStatus.taken:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
              SizedBox(width: 4),
              Text(
                'Taken',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );

      case DoseStatus.skipped:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.skip_next_rounded, size: 14, color: Color(0xFFD97706)),
              SizedBox(width: 4),
              Text(
                'Skipped',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD97706),
                ),
              ),
            ],
          ),
        );

      case DoseStatus.missed:
        return InkWell(
          onTap: () => _showQuickActionSheet(context, ref),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.dangerLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cancel_rounded, size: 14, color: AppColors.danger),
                SizedBox(width: 4),
                Text(
                  'Missed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
          ),
        );

      case DoseStatus.pending:
        return InkWell(
          onTap: () => _showQuickActionSheet(context, ref),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_rounded, size: 14, color: AppColors.navy),
                SizedBox(width: 4),
                Text(
                  'Pending',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  void _showQuickActionSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  dose.medicineName,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                Text(
                  '${dose.formattedTime} · ${dose.plannedQuantity.toInt()} ${dose.doseUnit}',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                  ),
                  title: const Text('Mark as Taken', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Updates inventory and records adherence'),
                  onTap: () async {
                    Navigator.pop(modalContext);
                    await ref.read(historyControllerProvider).markTaken(dose.id);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.skip_next_rounded, color: Color(0xFFD97706)),
                  ),
                  title: const Text('Skip Dose', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Record dose as skipped without deducting stock'),
                  onTap: () async {
                    Navigator.pop(modalContext);
                    await ref.read(historyControllerProvider).skipDose(dose.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _formIcon(MedicineForm form) {
    switch (form) {
      case MedicineForm.tablet:
      case MedicineForm.capsule:
        return Icons.medication_rounded;
      case MedicineForm.syrup:
      case MedicineForm.drops:
        return Icons.water_drop_rounded;
      case MedicineForm.injection:
        return Icons.vaccines_rounded;
      case MedicineForm.inhaler:
        return Icons.air_rounded;
      case MedicineForm.other:
        return Icons.medical_services_rounded;
    }
  }

  Color _iconBgColor(DoseStatus status) {
    switch (status) {
      case DoseStatus.taken:
        return AppColors.primaryLight;
      case DoseStatus.skipped:
        return const Color(0xFFFEF3C7);
      case DoseStatus.missed:
        return AppColors.dangerLight;
      case DoseStatus.pending:
        return AppColors.background;
    }
  }

  Color _iconColor(DoseStatus status) {
    switch (status) {
      case DoseStatus.taken:
        return AppColors.primary;
      case DoseStatus.skipped:
        return const Color(0xFFD97706);
      case DoseStatus.missed:
        return AppColors.danger;
      case DoseStatus.pending:
        return AppColors.navy;
    }
  }
}
