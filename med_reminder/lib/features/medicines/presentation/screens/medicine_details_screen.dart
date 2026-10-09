import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../dose_tracking/presentation/providers/dose_providers.dart';
import '../providers/medicine_providers.dart';

class MedicineDetailsScreen extends ConsumerStatefulWidget {
  final String medicineId;

  const MedicineDetailsScreen({
    super.key,
    required this.medicineId,
  });

  @override
  ConsumerState<MedicineDetailsScreen> createState() => _MedicineDetailsScreenState();
}

class _MedicineDetailsScreenState extends ConsumerState<MedicineDetailsScreen> {
  bool _isDeleting = false;

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Delete Medicine', style: AppTypography.titleMedium),
          content: const Text(
            'Are you sure you want to delete this medicine? Future scheduled reminders will be cancelled, but past dose history will be kept.',
            style: AppTypography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                setState(() => _isDeleting = true);

                final medRepo = ref.read(medicineRepositoryProvider);
                final doseRepo = ref.read(doseRepositoryProvider);

                await medRepo.deleteMedicine(widget.medicineId);
                await doseRepo.deleteFuturePendingDosesForMedicine(widget.medicineId);

                ref.invalidate(medicinesListProvider);
                ref.invalidate(todayDosesProvider);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Medicine deleted'),
                      backgroundColor: AppColors.danger,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.pop();
                }
              },
              child: const Text('Delete', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(getMedicineDetailsUseCaseProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Medicine Details', style: AppTypography.titleMedium),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit medicine feature ready in next phase'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              'Edit',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder(
        future: detailsAsync.execute(widget.medicineId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: AppColors.danger),
              ),
            );
          }

          final data = snapshot.data!;
          final medicine = data.medicine;
          final schedules = data.schedules;

          final formattedStart = DateFormat('d MMM yyyy').format(medicine.startDate);
          final dailyDoseCount = schedules.length;
          final dosageText = schedules.isNotEmpty
              ? '${schedules.first.doseQuantity.toInt()} ${schedules.first.doseUnit}'
              : '1 ${medicine.form.displayName.toLowerCase()}';

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Medicine Header Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: AppColors.dangerLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.medication_rounded,
                                  color: AppColors.danger,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      medicine.name,
                                      style: AppTypography.displayMedium.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.navy,
                                      ),
                                    ),
                                    if (medicine.strength != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        medicine.strength!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        _buildChip(medicine.form.displayName),
                                        if (medicine.category != null)
                                          _buildChip(medicine.category!),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Information Key-Value Rows
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow('Total Quantity', '${medicine.totalQuantity.toInt()}'),
                              const Divider(color: AppColors.borderSubtle, height: 20),
                              _buildInfoRow(
                                'Remaining',
                                '${medicine.remainingQuantity.toInt()}',
                                isHighlighted: medicine.isRunningLow,
                              ),
                              const Divider(color: AppColors.borderSubtle, height: 20),
                              _buildInfoRow('Dosage', dosageText),
                              const Divider(color: AppColors.borderSubtle, height: 20),
                              _buildInfoRow('Times per day', '$dailyDoseCount'),
                              const Divider(color: AppColors.borderSubtle, height: 20),
                              _buildInfoRow('Start Date', formattedStart),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Schedules Section
                        const Text('Schedule', style: AppTypography.titleMedium),
                        const SizedBox(height: 12),
                        ...schedules.map((schedule) {
                          final isNight = schedule.hour >= 18 || schedule.hour < 5;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                                  color: isNight ? AppColors.navy : AppColors.warning,
                                  size: 20,
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  schedule.formattedTime,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.navy,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    schedule.instruction ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Delete Medicine Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: AppButton(
                    label: 'Delete Medicine',
                    variant: AppButtonVariant.danger,
                    isLoading: _isDeleting,
                    onPressed: _confirmDelete,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isHighlighted ? AppColors.danger : AppColors.navy,
          ),
        ),
      ],
    );
  }
}
