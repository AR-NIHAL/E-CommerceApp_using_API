import '../entities/dose_occurrence.dart';
import '../repositories/dose_repository.dart';

class GetDosesByDateRangeUseCase {
  final DoseRepository repository;

  const GetDosesByDateRangeUseCase(this.repository);

  Future<List<DoseOccurrence>> execute(DateTime start, DateTime end) async {
    return await repository.getDosesForDateRange(start, end);
  }
}
