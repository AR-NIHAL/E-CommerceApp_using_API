import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_2/features/dose_tracking/presentation/providers/dose_providers.dart';
import 'package:flutter_application_2/features/medicines/presentation/providers/medicine_providers.dart';
import '../../domain/entities/stats_models.dart';
import '../../domain/usecases/get_stats_usecase.dart';

/// Currently selected timeframe for the statistics screen.
final statsTimeframeProvider = StateProvider<StatsTimeframe>((ref) {
  return StatsTimeframe.weekly;
});

/// UseCase provider for statistics calculation.
final getStatsUseCaseProvider = Provider<GetStatsUseCase>((ref) {
  return GetStatsUseCase(
    doseRepository: ref.watch(doseRepositoryProvider),
    medicineRepository: ref.watch(medicineRepositoryProvider),
  );
});

/// Asynchronously computes overall adherence statistics based on active timeframe.
final statsDataAsyncProvider = FutureProvider<OverallStats>((ref) async {
  final timeframe = ref.watch(statsTimeframeProvider);
  final useCase = ref.watch(getStatsUseCaseProvider);
  return await useCase.execute(timeframe: timeframe);
});
