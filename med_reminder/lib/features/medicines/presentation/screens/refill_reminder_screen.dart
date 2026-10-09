import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/medicine.dart';
import '../providers/medicine_providers.dart';

class RefillReminderScreen extends ConsumerStatefulWidget {
  const RefillReminderScreen({super.key});

  @override
  ConsumerState<RefillReminderScreen> createState() => _RefillReminderScreenState();
}

class _RefillReminderScreenState extends ConsumerState<RefillReminderScreen> {
  void _showRefillDialog(Medicine medicine) {
    final qtyController = TextEditingController(text: '30');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Refill ${medicine.name}',
            style: AppTypography.titleMedium,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current stock: ${medicine.remainingQuantity.toInt()} ${medicine.form.displayName.toLowerCase()}s',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 16),
              const Text('Add Quantity', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                autofocus: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'e.g. 30',
                  suffixText: medicine.form.displayName.toLowerCase(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final added = double.tryParse(qtyController.text.trim()) ?? 0;
                if (added > 0) {
                  Navigator.pop(dialogContext);
                  await ref.read(refillMedicineUseCaseProvider).execute(
                        medicineId: medicine.id,
                        addedQuantity: added,
                      );
                  ref.invalidate(medicinesListProvider);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${added.toInt()} ${medicine.name} to stock'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text('Refill Stock'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final medicinesAsync = ref.watch(medicinesListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Refill Reminder', style: AppTypography.titleMedium),
        centerTitle: true,
      ),
      body: medicinesAsync.when(
        data: (medicines) {
          final runningLow = medicines.where((m) => m.isRunningLow).toList();
          final refillSoon = medicines.where((m) {
            return !m.isRunningLow && m.remainingQuantity <= (m.refillThreshold * 2.5);
          }).toList();

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // 1. Running Low Alerts (Red)
                ...runningLow.map((med) {
                  return _buildAlertCard(
                    title: 'Running low',
                    medicineName: med.strength != null ? '${med.name} ${med.strength}' : med.name,
                    remainingText: 'Only ${med.remainingQuantity.toInt()} ${med.form.displayName.toLowerCase()}s remaining',
                    estimateText: 'Estimated to last ${_estimateDays(med)}',
                    isDanger: true,
                    onTap: () => _showRefillDialog(med),
                  );
                }),

                // 2. Refill Soon Alerts (Green)
                ...refillSoon.map((med) {
                  return _buildAlertCard(
                    title: 'Time to refill soon',
                    medicineName: med.strength != null ? '${med.name} ${med.strength}' : med.name,
                    remainingText: '${med.remainingQuantity.toInt()} ${med.form.displayName.toLowerCase()}s remaining',
                    estimateText: 'Estimated to last ${_estimateDays(med)}',
                    isDanger: false,
                    onTap: () => _showRefillDialog(med),
                  );
                }),

                const SizedBox(height: 16),
                // 3. All Medicines Section
                const Text('All Medicines', style: AppTypography.titleMedium),
                const SizedBox(height: 12),

                if (medicines.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Text('No medicines added yet', style: AppTypography.bodyMedium),
                    ),
                  )
                else
                  ...medicines.map((med) {
                    final isLow = med.isRunningLow;
                    final isNear = med.remainingQuantity <= (med.refillThreshold * 2);

                    Color textColor = AppColors.success;
                    if (isLow) {
                      textColor = AppColors.danger;
                    } else if (isNear) {
                      textColor = AppColors.warning;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isLow ? AppColors.dangerLight : AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.medication_rounded,
                              color: isLow ? AppColors.danger : AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              med.strength != null ? '${med.name} ${med.strength}' : med.name,
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.navy,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '${med.remainingQuantity.toInt()} left',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 22),
                            onPressed: () => _showRefillDialog(med),
                            tooltip: 'Refill stock',
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.danger))),
      ),
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String medicineName,
    required String remainingText,
    required String estimateText,
    required bool isDanger,
    required VoidCallback onTap,
  }) {
    final bgColor = isDanger ? AppColors.dangerLight : AppColors.successLight;
    final iconColor = isDanger ? AppColors.danger : AppColors.success;
    final iconData = isDanger ? Icons.warning_amber_rounded : Icons.info_outline_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        medicineName,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        remainingText,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        estimateText,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _estimateDays(Medicine medicine) {
    if (medicine.remainingQuantity <= 0) return '0 days (Out of stock)';
    // Rough estimate: 2 doses/day average or 1 week
    final days = (medicine.remainingQuantity / 2).ceil();
    if (days >= 7) {
      final weeks = (days / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'}';
    }
    return '$days days';
  }
}
