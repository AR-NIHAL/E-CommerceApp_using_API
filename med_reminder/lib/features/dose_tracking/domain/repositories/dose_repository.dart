import '../entities/dose_occurrence.dart';

/// Contract defining persistence operations for daily dose occurrences.
abstract class DoseRepository {
  /// Retrieves all doses falling within a specific date range [start] to [end] in local time.
  Future<List<DoseOccurrence>> getDosesForDateRange(DateTime start, DateTime end);

  /// Retrieves all doses for today (from 00:00:00 to 23:59:59 local time).
  Future<List<DoseOccurrence>> getTodayDoses();

  /// Retrieves a specific dose occurrence by its ID.
  Future<DoseOccurrence?> getDoseById(String id);

  /// Saves a batch of occurrences.
  /// If an occurrence with the same ID already exists and was taken or skipped,
  /// its historical status must be preserved (idempotent write).
  Future<void> saveOccurrences(List<DoseOccurrence> occurrences);

  /// Updates status and action time of a specific dose.
  Future<void> updateDoseStatus(String id, DoseStatus status, DateTime? actionAtUtc);

  /// Deletes future pending occurrences for a medicine (e.g. upon edit or deletion).
  Future<void> deleteFuturePendingDosesForMedicine(String medicineId);

  /// Gets all doses stored in the system (used for adherence calculations).
  Future<List<DoseOccurrence>> getAllDoses();
}
