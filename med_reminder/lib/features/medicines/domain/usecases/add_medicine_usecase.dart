import '../../../../core/errors/failures.dart';
import '../entities/medicine.dart';
import '../entities/medicine_schedule.dart';
import '../repositories/medicine_repository.dart';

class AddMedicineUseCase {
  final MedicineRepository repository;

  const AddMedicineUseCase(this.repository);

  Future<void> execute({
    required Medicine medicine,
    required List<MedicineSchedule> schedules,
  }) async {
    // 1. Validation
    if (medicine.name.trim().isEmpty) {
      throw const ValidationFailure('Medicine name cannot be empty');
    }
    if (medicine.totalQuantity < 0 || medicine.remainingQuantity < 0) {
      throw const ValidationFailure('Quantity cannot be negative');
    }
    if (schedules.isEmpty) {
      throw const ValidationFailure('At least one schedule time is required');
    }
    if (medicine.endDate != null && medicine.endDate!.isBefore(medicine.startDate)) {
      throw const ValidationFailure('End date cannot be before start date');
    }

    // 2. Persist
    await repository.saveMedicine(medicine, schedules);
  }
}
