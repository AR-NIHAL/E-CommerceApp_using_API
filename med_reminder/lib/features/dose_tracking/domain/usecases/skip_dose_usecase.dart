import '../../../../core/errors/failures.dart';
import '../entities/dose_occurrence.dart';
import '../repositories/dose_repository.dart';

class SkipDoseUseCase {
  final DoseRepository doseRepository;

  const SkipDoseUseCase(this.doseRepository);

  /// Marks a dose as skipped without deducting inventory.
  Future<DoseOccurrence> execute(String occurrenceId) async {
    final dose = await doseRepository.getDoseById(occurrenceId);
    if (dose == null) {
      throw const NotFoundFailure('Dose occurrence not found');
    }

    final nowUtc = DateTime.now().toUtc();
    await doseRepository.updateDoseStatus(
      occurrenceId,
      DoseStatus.skipped,
      nowUtc,
    );

    return dose.copyWith(
      status: DoseStatus.skipped,
      actionAtUtc: nowUtc,
    );
  }
}
