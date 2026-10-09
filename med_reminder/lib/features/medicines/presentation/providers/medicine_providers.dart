import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../core/local/hive_service.dart';
import '../../data/models/medicine_hive_model.dart';
import '../../data/models/medicine_schedule_hive_model.dart';
import '../../data/models/refill_record_hive_model.dart';
import '../../data/repositories/medicine_repository_impl.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../../domain/usecases/add_medicine_usecase.dart';
import '../../domain/usecases/delete_medicine_usecase.dart';
import '../../domain/usecases/get_medicine_details_usecase.dart';
import '../../domain/usecases/get_medicines_usecase.dart';
import '../../domain/usecases/refill_medicine_usecase.dart';

/// Provides the concrete MedicineRepository instance backed by Hive.
final medicineRepositoryProvider = Provider<MedicineRepository>((ref) {
  final medicinesBox = Hive.box<MedicineHiveModel>(HiveService.medicinesBox);
  final schedulesBox = Hive.box<MedicineScheduleHiveModel>(HiveService.schedulesBox);
  final refillsBox = Hive.box<RefillRecordHiveModel>(HiveService.refillRecordsBox);

  return MedicineRepositoryImpl(
    medicinesBox: medicinesBox,
    schedulesBox: schedulesBox,
    refillsBox: refillsBox,
  );
});

// Domain UseCases providers
final addMedicineUseCaseProvider = Provider<AddMedicineUseCase>((ref) {
  return AddMedicineUseCase(ref.watch(medicineRepositoryProvider));
});

final getMedicinesUseCaseProvider = Provider<GetMedicinesUseCase>((ref) {
  return GetMedicinesUseCase(ref.watch(medicineRepositoryProvider));
});

final getMedicineDetailsUseCaseProvider = Provider<GetMedicineDetailsUseCase>((ref) {
  return GetMedicineDetailsUseCase(ref.watch(medicineRepositoryProvider));
});

final deleteMedicineUseCaseProvider = Provider<DeleteMedicineUseCase>((ref) {
  return DeleteMedicineUseCase(ref.watch(medicineRepositoryProvider));
});

final refillMedicineUseCaseProvider = Provider<RefillMedicineUseCase>((ref) {
  return RefillMedicineUseCase(ref.watch(medicineRepositoryProvider));
});

/// Async notifier for the list of active medicines.
class MedicinesListNotifier extends AsyncNotifier<List<Medicine>> {
  @override
  Future<List<Medicine>> build() async {
    return ref.watch(getMedicinesUseCaseProvider).execute();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(getMedicinesUseCaseProvider).execute(),
    );
  }
}

final medicinesListProvider =
    AsyncNotifierProvider<MedicinesListNotifier, List<Medicine>>(
  MedicinesListNotifier.new,
);
