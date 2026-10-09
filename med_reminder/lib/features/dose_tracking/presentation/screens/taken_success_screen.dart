import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import 'package:flutter_application_2/features/medicines/presentation/providers/medicine_providers.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/entities/dose_occurrence.dart';

class TakenSuccessScreen extends ConsumerWidget {
  final DoseOccurrence dose;

  const TakenSuccessScreen({
    super.key,
    required this.dose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch medicine to get live updated remaining quantity
    final medicinesAsync = ref.watch(medicinesListProvider);
    final medicine = medicinesAsync.valueOrNull?.where((m) => m.id == dose.medicineId).firstOrNull;

    final remainingText = medicine != null
        ? '${medicine.remainingQuantity.toInt()} / ${medicine.totalQuantity.toInt()}'
        : 'Updated';

    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final p = now.hour >= 12 ? 'PM' : 'AM';
    final takenTime = '$h:$m $p';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const Spacer(),
              // Celebratory Confetti & Checkmark Graphic
              SizedBox(
                width: 180,
                height: 180,
                child: CustomPaint(
                  painter: _ConfettiPainter(),
                  child: Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_rounded,
                          color: AppColors.success,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Well Done Title
              Text(
                'Well done!',
                style: AppTypography.displayMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "You've taken your medicine",
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              // Medicine name & strength
              Text(
                dose.strength != null
                    ? '${dose.medicineName} ${dose.strength}'
                    : dose.medicineName,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              // Taken Time tag
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    takenTime,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Remaining tablets card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.warning,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Remaining tablets',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            remainingText,
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w700,
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
              const Spacer(),
              // Done Button
              AppButton(
                label: 'Done',
                onPressed: () => context.go('/'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final random = Random(42);

    final colors = [
      AppColors.primary,
      AppColors.warning,
      AppColors.info,
      AppColors.danger,
    ];

    for (int i = 0; i < 16; i++) {
      final angle = (i * (2 * pi / 16));
      final distance = 68.0 + (random.nextDouble() * 14.0);
      final x = center.dx + distance * cos(angle);
      final y = center.dy + distance * sin(angle);

      final color = colors[i % colors.length];
      final paint = Paint()
        ..color = color.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;

      // Small confetti capsule / dot
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-3, -8, 6, 16),
          const Radius.circular(3),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
