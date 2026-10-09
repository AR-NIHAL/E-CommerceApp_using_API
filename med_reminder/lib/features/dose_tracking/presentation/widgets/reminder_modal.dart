import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/entities/dose_occurrence.dart';
import '../providers/dose_providers.dart';

class ReminderModal extends ConsumerStatefulWidget {
  final DoseOccurrence dose;

  const ReminderModal({
    super.key,
    required this.dose,
  });

  static Future<void> show(BuildContext context, DoseOccurrence dose) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => ReminderModal(dose: dose),
    );
  }

  @override
  ConsumerState<ReminderModal> createState() => _ReminderModalState();
}

class _ReminderModalState extends ConsumerState<ReminderModal> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final dose = widget.dose;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button on top right
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Circular pill illustration badge
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.dangerLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.medication_rounded,
                color: AppColors.danger,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Heading
          Text(
            'Time to take your medicine!',
            style: AppTypography.titleLarge.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 12),
          // Medicine name & strength
          Text(
            dose.strength != null
                ? '${dose.medicineName} ${dose.strength}'
                : dose.medicineName,
            style: AppTypography.titleMedium.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          // Instruction
          Text(
            '${dose.plannedQuantity.toInt()} ${dose.doseUnit}'
            '${dose.instruction != null ? ' · ${dose.instruction}' : ''}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          // Scheduled Time tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time_rounded, size: 16, color: AppColors.navy),
                const SizedBox(width: 6),
                Text(
                  dose.formattedTime,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Primary Action: Mark as Taken
          AppButton(
            label: '✓ Mark as Taken',
            isLoading: _isLoading,
            onPressed: () async {
              final navigator = Navigator.of(context);
              final router = GoRouter.of(context);
              setState(() => _isLoading = true);
              await ref.read(todayDosesProvider.notifier).markTaken(dose.id);
              navigator.pop();
              router.push('/taken-success', extra: dose);
            },
          ),
          const SizedBox(height: 12),
          // Secondary Action: Skip for now
          AppButton(
            label: 'Skip for now',
            variant: AppButtonVariant.ghost,
            onPressed: () async {
              final navigator = Navigator.of(context);
              await ref.read(todayDosesProvider.notifier).skip(dose.id);
              navigator.pop();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
