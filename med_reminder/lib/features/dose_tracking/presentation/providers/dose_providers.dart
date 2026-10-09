import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:flutter_application_2/core/local/hive_service.dart';
import 'package:flutter_application_2/core/notifications/notification_providers.dart';
import 'package:flutter_application_2/features/medicines/presentation/providers/medicine_providers.dart';
import 'package:flutter_application_2/features/dose_tracking/data/models/dose_occurrence_hive_model.dart';
import 'package:flutter_application_2/features/dose_tracking/data/repositories/dose_repository_impl.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/entities/dose_occurrence.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/repositories/dose_repository.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/services/dose_occurrence_generator.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/usecases/generate_occurrences_usecase.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/usecases/get_doses_by_date_range_usecase.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/usecases/get_today_doses_usecase.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/usecases/mark_dose_taken_usecase.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/usecases/skip_dose_usecase.dart';

/// Provides concrete DoseRepository backed by Hive box.
final doseRepositoryProvider = Provider<DoseRepository>((ref) {
  final doseBox = Hive.box<DoseOccurrenceHiveModel>(HiveService.doseOccurrencesBox);
  return DoseRepositoryImpl(doseBox: doseBox);
});

final doseOccurrenceGeneratorProvider = Provider<DoseOccurrenceGenerator>((ref) {
  return const DoseOccurrenceGenerator();
});

final generateOccurrencesUseCaseProvider = Provider<GenerateOccurrencesUseCase>((ref) {
  return GenerateOccurrencesUseCase(
    doseRepository: ref.watch(doseRepositoryProvider),
    generator: ref.watch(doseOccurrenceGeneratorProvider),
  );
});

final getTodayDosesUseCaseProvider = Provider<GetTodayDosesUseCase>((ref) {
  return GetTodayDosesUseCase(ref.watch(doseRepositoryProvider));
});

final markDoseTakenUseCaseProvider = Provider<MarkDoseTakenUseCase>((ref) {
  return MarkDoseTakenUseCase(
    doseRepository: ref.watch(doseRepositoryProvider),
    medicineRepository: ref.watch(medicineRepositoryProvider),
  );
});

final skipDoseUseCaseProvider = Provider<SkipDoseUseCase>((ref) {
  return SkipDoseUseCase(ref.watch(doseRepositoryProvider));
});

final getDosesByDateRangeUseCaseProvider = Provider<GetDosesByDateRangeUseCase>((ref) {
  return GetDosesByDateRangeUseCase(ref.watch(doseRepositoryProvider));
});

/// Async notifier for Today's scheduled doses.
class TodayDosesNotifier extends AsyncNotifier<List<DoseOccurrence>> {
  @override
  Future<List<DoseOccurrence>> build() async {
    return ref.watch(getTodayDosesUseCaseProvider).execute();
  }

  Future<void> markTaken(String occurrenceId) async {
    await ref.read(markDoseTakenUseCaseProvider).execute(occurrenceId);
    await ref.read(notificationServiceProvider).cancelDose(occurrenceId);
    // Refresh medicines list to show updated inventory
    ref.invalidate(medicinesListProvider);
    // Refresh today's doses
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(getTodayDosesUseCaseProvider).execute(),
    );
  }

  Future<void> skip(String occurrenceId) async {
    await ref.read(skipDoseUseCaseProvider).execute(occurrenceId);
    await ref.read(notificationServiceProvider).cancelDose(occurrenceId);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(getTodayDosesUseCaseProvider).execute(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(getTodayDosesUseCaseProvider).execute(),
    );
  }
}

final todayDosesProvider =
    AsyncNotifierProvider<TodayDosesNotifier, List<DoseOccurrence>>(
  TodayDosesNotifier.new,
);
