import '../entities/medicine.dart';
import '../entities/medicine_schedule.dart';
import '../entities/refill_record.dart';

/// Contract defining persistence operations for Medicines, Schedules, and Refill history.
abstract class MedicineRepository {
  /// Retrieves all medicines. If [activeOnly] is true, returns only non-deleted ones.
  Future<List<Medicine>> getMedicines({bool activeOnly = true});

  /// Finds a specific medicine by ID.
  Future<Medicine?> getMedicineById(String id);

  /// Saves or updates a medicine along with its associated schedules atomically.
  Future<void> saveMedicine(Medicine medicine, List<MedicineSchedule> schedules);

  /// Updates just the medicine definition.
  Future<void> updateMedicine(Medicine medicine);

  /// Soft deletes a medicine (marks isActive = false) to preserve historical data.
  Future<void> deleteMedicine(String id);

  /// Updates remaining quantity (used when a dose is taken or stock is adjusted).
  Future<void> updateRemainingQuantity(String id, double newQuantity);

  /// Gets all schedules associated with a medicine.
  Future<List<MedicineSchedule>> getSchedulesForMedicine(String medicineId);

  /// Gets all active schedules across all active medicines.
  Future<List<MedicineSchedule>> getAllActiveSchedules();

  /// Logs a refill record and adds stock to the medicine.
  Future<void> recordRefill(RefillRecord record);

  /// Retrieves refill audit history for a medicine.
  Future<List<RefillRecord>> getRefillRecords(String medicineId);
}
