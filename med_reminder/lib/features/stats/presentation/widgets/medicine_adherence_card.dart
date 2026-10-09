import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../medicines/domain/entities/medicine.dart';
import '../../domain/entities/stats_models.dart';

class MedicineAdherenceCard extends StatelessWidget {
  final List<MedicineAdherence> medicines;

  const MedicineAdherenceCard({
    super.key,
    required this.medicines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Medication Breakdown',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              Text(
                '${medicines.length} ${medicines.length == 1 ? 'medicine' : 'medicines'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (medicines.isEmpty) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No medications tracked for this period',
                  style: AppTypography.bodySmall,
                ),
              ),
            ),
          ] else ...[
            ...medicines.map((med) => _buildMedicineRow(med)),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicineRow(MedicineAdherence med) {
    final percent = (med.adherenceRate * 100).round();
    final hasDoses = med.totalDoses > 0;

    Color badgeBg;
    Color badgeText;
    if (!hasDoses) {
      badgeBg = AppColors.background;
      badgeText = AppColors.textSecondary;
    } else if (percent >= 80) {
      badgeBg = AppColors.primaryLight;
      badgeText = AppColors.primary;
    } else if (percent >= 50) {
      badgeBg = const Color(0xFFFEF3C7);
      badgeText = const Color(0xFFD97706);
    } else {
      badgeBg = AppColors.dangerLight;
      badgeText = AppColors.danger;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _formIcon(med.form),
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.strength != null
                          ? '${med.medicineName} ${med.strength}'
                          : med.medicineName,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasDoses
                          ? '${med.takenDoses}/${med.totalDoses} doses taken'
                          : 'No doses scheduled',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  hasDoses ? '$percent%' : '--',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: badgeText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: hasDoses ? med.adherenceRate : 0.0,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(
                percent >= 80 ? AppColors.primary : AppColors.warning,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
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
}
