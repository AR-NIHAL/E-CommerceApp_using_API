import '../repositories/medicine_repository.dart';

class DeleteMedicineUseCase {
  final MedicineRepository repository;

  const DeleteMedicineUseCase(this.repository);

  Future<void> execute(String medicineId) async {
    await repository.deleteMedicine(medicineId);
  }
}
