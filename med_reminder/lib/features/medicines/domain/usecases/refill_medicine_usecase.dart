import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../entities/refill_record.dart';
import '../repositories/medicine_repository.dart';

class RefillMedicineUseCase {
  final MedicineRepository repository;
  final Uuid _uuid;

  RefillMedicineUseCase(this.repository, [Uuid? uuid]) : _uuid = uuid ?? const Uuid();

  Future<void> execute({
    required String medicineId,
    required double addedQuantity,
  }) async {
    if (addedQuantity <= 0) {
      throw const ValidationFailure('Refill quantity must be greater than zero');
    }

    final medicine = await repository.getMedicineById(medicineId);
    if (medicine == null) {
      throw const NotFoundFailure('Medicine not found');
    }

    final newRemaining = medicine.remainingQuantity + addedQuantity;
    await repository.updateRemainingQuantity(medicineId, newRemaining);

    final record = RefillRecord(
      id: _uuid.v4(),
      medicineId: medicineId,
      addedQuantity: addedQuantity,
      refilledAt: DateTime.now().toUtc(),
    );
    await repository.recordRefill(record);
  }
}
