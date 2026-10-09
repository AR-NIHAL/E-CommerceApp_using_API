import 'package:hive_flutter/hive_flutter.dart';
import '../../features/dose_tracking/data/models/dose_occurrence_hive_model.dart';
import '../../features/medicines/data/models/medicine_hive_model.dart';
import '../../features/medicines/data/models/medicine_schedule_hive_model.dart';
import '../../features/medicines/data/models/refill_record_hive_model.dart';

/// Centralized service for initializing Hive and managing Box names and Type IDs.
abstract final class HiveService {
  // Box names
  static const String medicinesBox = 'medicines_box';
  static const String schedulesBox = 'schedules_box';
  static const String doseOccurrencesBox = 'dose_occurrences_box';
  static const String refillRecordsBox = 'refill_records_box';
  static const String appSettingsBox = 'app_settings_box';

  // Type IDs for HiveAdapters (0-223)
  static const int medicineTypeId = 0;
  static const int medicineScheduleTypeId = 1;
  static const int doseOccurrenceTypeId = 2;
  static const int refillRecordTypeId = 3;

  /// Initializes Hive for Flutter.
  static Future<void> init() async {
    await Hive.initFlutter();
    _registerAdapters();
    await _openInitialBoxes();
  }

  /// Registers all TypeAdapters if not already registered.
  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(medicineTypeId)) {
      Hive.registerAdapter(MedicineHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(medicineScheduleTypeId)) {
      Hive.registerAdapter(MedicineScheduleHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(doseOccurrenceTypeId)) {
      Hive.registerAdapter(DoseOccurrenceHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(refillRecordTypeId)) {
      Hive.registerAdapter(RefillRecordHiveModelAdapter());
    }
  }

  /// Opens standard typed boxes.
  static Future<void> _openInitialBoxes() async {
    if (!Hive.isBoxOpen(medicinesBox)) {
      await Hive.openBox<MedicineHiveModel>(medicinesBox);
    }
    if (!Hive.isBoxOpen(schedulesBox)) {
      await Hive.openBox<MedicineScheduleHiveModel>(schedulesBox);
    }
    if (!Hive.isBoxOpen(doseOccurrencesBox)) {
      await Hive.openBox<DoseOccurrenceHiveModel>(doseOccurrencesBox);
    }
    if (!Hive.isBoxOpen(refillRecordsBox)) {
      await Hive.openBox<RefillRecordHiveModel>(refillRecordsBox);
    }
    if (!Hive.isBoxOpen(appSettingsBox)) {
      await Hive.openBox<dynamic>(appSettingsBox);
    }
  }

  /// Closes all opened boxes cleanly.
  static Future<void> closeAll() async {
    await Hive.close();
  }
}
