import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/notifications/notification_providers.dart';
import '../../../dose_tracking/presentation/providers/dose_providers.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/entities/medicine_schedule.dart';
import '../providers/medicine_providers.dart';

/// Single schedule entry inside the Add Medicine form.
class ScheduleInputItem {
  final String id;
  final TimeOfDay time;
  final String instruction; // e.g. "After breakfast", "After dinner"
  final double doseQuantity;
  final String doseUnit;

  const ScheduleInputItem({
    required this.id,
    required this.time,
    required this.instruction,
    this.doseQuantity = 1.0,
    this.doseUnit = 'tablet',
  });

  String get formattedTime {
    final hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minuteStr = time.minute.toString().padLeft(2, '0');
    final periodStr = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour12:$minuteStr $periodStr';
  }

  ScheduleInputItem copyWith({
    String? id,
    TimeOfDay? time,
    String? instruction,
    double? doseQuantity,
    String? doseUnit,
  }) {
    return ScheduleInputItem(
      id: id ?? this.id,
      time: time ?? this.time,
      instruction: instruction ?? this.instruction,
      doseQuantity: doseQuantity ?? this.doseQuantity,
      doseUnit: doseUnit ?? this.doseUnit,
    );
  }
}

/// Form state for Add Medicine screen.
class AddMedicineFormState {
  final String name;
  final String strength;
  final String dosage;
  final MedicineForm form;
  final String totalQuantity;
  final List<ScheduleInputItem> schedules;
  final bool isLoading;
  final String? errorMessage;
  final bool isSaved;

  const AddMedicineFormState({
    this.name = '',
    this.strength = '',
    this.dosage = '1 tablet',
    this.form = MedicineForm.tablet,
    this.totalQuantity = '30',
    this.schedules = const [
      ScheduleInputItem(
        id: '1',
        time: TimeOfDay(hour: 8, minute: 0),
        instruction: 'After breakfast',
      ),
      ScheduleInputItem(
        id: '2',
        time: TimeOfDay(hour: 21, minute: 0),
        instruction: 'After dinner',
      ),
    ],
    this.isLoading = false,
    this.errorMessage,
    this.isSaved = false,
  });

  AddMedicineFormState copyWith({
    String? name,
    String? strength,
    String? dosage,
    MedicineForm? form,
    String? totalQuantity,
    List<ScheduleInputItem>? schedules,
    bool? isLoading,
    String? errorMessage,
    bool? isSaved,
  }) {
    return AddMedicineFormState(
      name: name ?? this.name,
      strength: strength ?? this.strength,
      dosage: dosage ?? this.dosage,
      form: form ?? this.form,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

class AddMedicineNotifier extends StateNotifier<AddMedicineFormState> {
  final Ref _ref;
  final Uuid _uuid;

  AddMedicineNotifier(this._ref, [Uuid? uuid])
      : _uuid = uuid ?? const Uuid(),
        super(const AddMedicineFormState());

  void setName(String value) {
    state = state.copyWith(name: value, errorMessage: null);
  }

  void setStrength(String value) {
    state = state.copyWith(strength: value, errorMessage: null);
  }

  void setDosage(String value) {
    state = state.copyWith(dosage: value, errorMessage: null);
  }

  void setForm(MedicineForm form) {
    state = state.copyWith(form: form);
  }

  void setTotalQuantity(String value) {
    state = state.copyWith(totalQuantity: value, errorMessage: null);
  }

  void addSchedule(TimeOfDay time, String instruction) {
    final newItem = ScheduleInputItem(
      id: _uuid.v4(),
      time: time,
      instruction: instruction,
    );
    final updated = List<ScheduleInputItem>.from(state.schedules)..add(newItem);
    state = state.copyWith(schedules: updated, errorMessage: null);
  }

  void removeSchedule(String id) {
    if (state.schedules.length <= 1) {
      state = state.copyWith(
        errorMessage: 'At least one schedule time is required',
      );
      return;
    }
    final updated = state.schedules.where((s) => s.id != id).toList();
    state = state.copyWith(schedules: updated, errorMessage: null);
  }

  Future<bool> saveMedicine() async {
    // 1. Validations
    if (state.name.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter a medicine name');
      return false;
    }

    final totalQty = double.tryParse(state.totalQuantity.trim()) ?? 0;
    if (totalQty <= 0) {
      state = state.copyWith(errorMessage: 'Please enter a valid total quantity');
      return false;
    }

    if (state.schedules.isEmpty) {
      state = state.copyWith(errorMessage: 'Please add at least one schedule time');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final now = DateTime.now();
      final medicineId = _uuid.v4();

      final medicine = Medicine(
        id: medicineId,
        name: state.name.trim(),
        strength: state.strength.trim().isEmpty ? null : state.strength.trim(),
        form: state.form,
        totalQuantity: totalQty,
        remainingQuantity: totalQty,
        startDate: now,
        refillThreshold: 5.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final schedules = state.schedules.map((item) {
        return MedicineSchedule(
          id: item.id.length > 10 ? item.id : _uuid.v4(),
          medicineId: medicineId,
          hour: item.time.hour,
          minute: item.time.minute,
          doseQuantity: item.doseQuantity,
          doseUnit: state.form.displayName.toLowerCase(),
          instruction: item.instruction,
          weekDays: const {1, 2, 3, 4, 5, 6, 7},
          reminderEnabled: true,
        );
      }).toList();

      // Persist medicine and schedules
      await _ref.read(addMedicineUseCaseProvider).execute(
            medicine: medicine,
            schedules: schedules,
          );

      // Generate upcoming occurrences for the next 30 days
      final occurrences = await _ref.read(generateOccurrencesUseCaseProvider).execute(
            medicine: medicine,
            schedules: schedules,
            daysAhead: 30,
          );

      // Schedule exact alarms for upcoming doses
      await _ref.read(notificationServiceProvider).schedulePendingDoses(occurrences);

      // Invalidate lists so UI updates instantly
      _ref.invalidate(medicinesListProvider);
      _ref.invalidate(todayDosesProvider);

      state = state.copyWith(isLoading: false, isSaved: true);
      return true;
    } on Failure catch (f) {
      state = state.copyWith(isLoading: false, errorMessage: f.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  void reset() {
    state = const AddMedicineFormState();
  }
}

final addMedicineControllerProvider =
    StateNotifierProvider.autoDispose<AddMedicineNotifier, AddMedicineFormState>(
  (ref) => AddMedicineNotifier(ref),
);
