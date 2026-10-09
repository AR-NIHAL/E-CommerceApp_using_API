import '../entities/medicine.dart';
import '../repositories/medicine_repository.dart';

class GetMedicinesUseCase {
  final MedicineRepository repository;

  const GetMedicinesUseCase(this.repository);

  Future<List<Medicine>> execute({bool activeOnly = true}) async {
    return await repository.getMedicines(activeOnly: activeOnly);
  }
}
