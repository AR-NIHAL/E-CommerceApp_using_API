import '../entities/dose_occurrence.dart';
import '../repositories/dose_repository.dart';

class GetTodayDosesUseCase {
  final DoseRepository repository;

  const GetTodayDosesUseCase(this.repository);

  Future<List<DoseOccurrence>> execute() async {
    return await repository.getTodayDoses();
  }
}
