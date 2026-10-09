import '../../../../core/errors/failures.dart';
import '../entities/medicine.dart';
import '../entities/medicine_schedule.dart';
import '../entities/refill_record.dart';
import '../repositories/medicine_repository.dart';

class MedicineDetailsData {
  final Medicine medicine;
  final List<MedicineSchedule> schedules;
  final List<RefillRecord> refillHistory;

  const MedicineDetailsData({
    required this.medicine,
    required this.schedules,
    required this.refillHistory,
  });
}

class GetMedicineDetailsUseCase {
  final MedicineRepository repository;

  const GetMedicineDetailsUseCase(this.repository);

  Future<MedicineDetailsData> execute(String medicineId) async {
    final medicine = await repository.getMedicineById(medicineId);
    if (medicine == null) {
      throw const NotFoundFailure('Medicine not found');
    }

    final schedules = await repository.getSchedulesForMedicine(medicineId);
    final refills = await repository.getRefillRecords(medicineId);

    return MedicineDetailsData(
      medicine: medicine,
      schedules: schedules,
      refillHistory: refills,
    );
  }
}
