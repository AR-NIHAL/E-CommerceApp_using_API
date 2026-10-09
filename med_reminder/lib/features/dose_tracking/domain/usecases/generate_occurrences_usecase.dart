import 'package:flutter_application_2/features/medicines/domain/entities/medicine.dart';
import 'package:flutter_application_2/features/medicines/domain/entities/medicine_schedule.dart';
import '../entities/dose_occurrence.dart';
import '../repositories/dose_repository.dart';
import '../services/dose_occurrence_generator.dart';

class GenerateOccurrencesUseCase {
  final DoseRepository doseRepository;
  final DoseOccurrenceGenerator generator;

  const GenerateOccurrencesUseCase({
    required this.doseRepository,
    this.generator = const DoseOccurrenceGenerator(),
  });

  Future<List<DoseOccurrence>> execute({
    required Medicine medicine,
    required List<MedicineSchedule> schedules,
    int daysAhead = 30,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final until = today.add(Duration(days: daysAhead));

    final occurrences = generator.generate(
      medicine: medicine,
      schedules: schedules,
      from: today,
      until: until,
    );

    if (occurrences.isNotEmpty) {
      await doseRepository.saveOccurrences(occurrences);
    }

    return occurrences;
  }
}
