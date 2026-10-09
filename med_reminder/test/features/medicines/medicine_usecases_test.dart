import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/core/errors/failures.dart';
import 'package:flutter_application_2/features/medicines/domain/entities/medicine.dart';
import 'package:flutter_application_2/features/medicines/domain/entities/medicine_schedule.dart';
import 'package:flutter_application_2/features/medicines/domain/entities/refill_record.dart';
import 'package:flutter_application_2/features/medicines/domain/repositories/medicine_repository.dart';
import 'package:flutter_application_2/features/medicines/domain/usecases/add_medicine_usecase.dart';
import 'package:flutter_application_2/features/medicines/domain/usecases/refill_medicine_usecase.dart';

class FakeMedicineRepository implements MedicineRepository {
  final Map<String, Medicine> medicines = {};
  final Map<String, List<MedicineSchedule>> schedules = {};
  final List<RefillRecord> refills = [];

  @override
  Future<List<Medicine>> getMedicines({bool activeOnly = true}) async {
    return medicines.values.where((m) => !activeOnly || m.isActive).toList();
  }

  @override
  Future<Medicine?> getMedicineById(String id) async => medicines[id];

  @override
  Future<void> saveMedicine(Medicine medicine, List<MedicineSchedule> schedules) async {
    medicines[medicine.id] = medicine;
    this.schedules[medicine.id] = schedules;
  }

  @override
  Future<void> updateMedicine(Medicine medicine) async {
    medicines[medicine.id] = medicine;
  }

  @override
  Future<void> deleteMedicine(String id) async {
    final med = medicines[id];
    if (med != null) {
      medicines[id] = med.copyWith(isActive: false);
    }
  }

  @override
  Future<void> updateRemainingQuantity(String id, double newQuantity) async {
    final med = medicines[id];
    if (med != null) {
      medicines[id] = med.copyWith(remainingQuantity: newQuantity);
    }
  }

  @override
  Future<List<MedicineSchedule>> getSchedulesForMedicine(String medicineId) async {
    return schedules[medicineId] ?? [];
  }

  @override
  Future<List<MedicineSchedule>> getAllActiveSchedules() async {
    final activeIds = medicines.values.where((m) => m.isActive).map((m) => m.id).toSet();
    return schedules.values
        .expand((list) => list)
        .where((s) => activeIds.contains(s.medicineId))
        .toList();
  }

  @override
  Future<void> recordRefill(RefillRecord record) async {
    refills.add(record);
  }

  @override
  Future<List<RefillRecord>> getRefillRecords(String medicineId) async {
    return refills.where((r) => r.medicineId == medicineId).toList();
  }
}

void main() {
  late FakeMedicineRepository repository;
  late AddMedicineUseCase addMedicineUseCase;
  late RefillMedicineUseCase refillMedicineUseCase;

  setUp(() {
    repository = FakeMedicineRepository();
    addMedicineUseCase = AddMedicineUseCase(repository);
    refillMedicineUseCase = RefillMedicineUseCase(repository);
  });

  group('AddMedicineUseCase', () {
    final now = DateTime.now();

    test('should throw ValidationFailure if medicine name is empty', () async {
      final medicine = Medicine(
        id: 'med-1',
        name: '',
        form: MedicineForm.tablet,
        totalQuantity: 30,
        remainingQuantity: 30,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () => addMedicineUseCase.execute(
          medicine: medicine,
          schedules: [
            const MedicineSchedule(
              id: 'sched-1',
              medicineId: 'med-1',
              hour: 8,
              minute: 0,
            ),
          ],
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('should throw ValidationFailure if schedules list is empty', () async {
      final medicine = Medicine(
        id: 'med-1',
        name: 'Metformin',
        form: MedicineForm.tablet,
        totalQuantity: 30,
        remainingQuantity: 30,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () => addMedicineUseCase.execute(
          medicine: medicine,
          schedules: [],
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('should save medicine and schedules when valid', () async {
      final medicine = Medicine(
        id: 'med-1',
        name: 'Metformin',
        strength: '500mg',
        form: MedicineForm.tablet,
        totalQuantity: 30,
        remainingQuantity: 30,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );
      final schedules = [
        const MedicineSchedule(
          id: 'sched-1',
          medicineId: 'med-1',
          hour: 8,
          minute: 0,
          instruction: 'After breakfast',
        ),
        const MedicineSchedule(
          id: 'sched-2',
          medicineId: 'med-1',
          hour: 20,
          minute: 0,
          instruction: 'After dinner',
        ),
      ];

      await addMedicineUseCase.execute(medicine: medicine, schedules: schedules);

      final savedMed = await repository.getMedicineById('med-1');
      expect(savedMed, isNotNull);
      expect(savedMed!.name, 'Metformin');
      expect(savedMed.strength, '500mg');

      final savedSchedules = await repository.getSchedulesForMedicine('med-1');
      expect(savedSchedules.length, 2);
      expect(savedSchedules[0].hour, 8);
      expect(savedSchedules[1].hour, 20);
    });
  });

  group('RefillMedicineUseCase', () {
    final now = DateTime.now();

    test('should increase remainingQuantity and log RefillRecord', () async {
      final medicine = Medicine(
        id: 'med-2',
        name: 'Amlodipine',
        form: MedicineForm.tablet,
        totalQuantity: 30,
        remainingQuantity: 5,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );
      await repository.saveMedicine(medicine, []);

      await refillMedicineUseCase.execute(
        medicineId: 'med-2',
        addedQuantity: 20,
      );

      final updated = await repository.getMedicineById('med-2');
      expect(updated!.remainingQuantity, 25);

      final refills = await repository.getRefillRecords('med-2');
      expect(refills.length, 1);
      expect(refills.first.addedQuantity, 20);
    });

    test('should throw ValidationFailure if added quantity <= 0', () async {
      expect(
        () => refillMedicineUseCase.execute(
          medicineId: 'med-2',
          addedQuantity: 0,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });
}
