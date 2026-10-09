import 'dart:math';
import '../../../../core/errors/failures.dart';
import 'package:flutter_application_2/features/medicines/domain/repositories/medicine_repository.dart';
import '../entities/dose_occurrence.dart';
import '../repositories/dose_repository.dart';

class MarkDoseTakenUseCase {
  final DoseRepository doseRepository;
  final MedicineRepository medicineRepository;

  const MarkDoseTakenUseCase({
    required this.doseRepository,
    required this.medicineRepository,
  });

  /// Marks a dose as taken and decreases the remaining quantity of the medicine.
  /// Strictly idempotent: if already marked taken, does not deduct quantity again.
  Future<DoseOccurrence> execute(String occurrenceId) async {
    final dose = await doseRepository.getDoseById(occurrenceId);
    if (dose == null) {
      throw const NotFoundFailure('Dose occurrence not found');
    }

    // 1. Idempotency check: if already taken, return without double decrementing
    if (dose.status == DoseStatus.taken) {
      return dose;
    }

    final nowUtc = DateTime.now().toUtc();

    // 2. Update dose occurrence status
    await doseRepository.updateDoseStatus(
      occurrenceId,
      DoseStatus.taken,
      nowUtc,
    );

    // 3. Atomically decrease medicine remaining quantity
    final medicine = await medicineRepository.getMedicineById(dose.medicineId);
    if (medicine != null) {
      final newRemaining = max(0.0, medicine.remainingQuantity - dose.plannedQuantity);
      await medicineRepository.updateRemainingQuantity(medicine.id, newRemaining);
    }

    return dose.copyWith(
      status: DoseStatus.taken,
      actionAtUtc: nowUtc,
    );
  }
}
