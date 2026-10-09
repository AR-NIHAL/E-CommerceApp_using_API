/// Pure domain entity representing a specific scheduled dose time for a Medicine.
class MedicineSchedule {
  final String id;
  final String medicineId;
  final int hour; // 0 - 23
  final int minute; // 0 - 59
  final double doseQuantity; // e.g. 1.0
  final String doseUnit; // e.g. "tablet", "capsule", "ml"
  final String? instruction; // e.g. "After breakfast", "After dinner"
  final Set<int> weekDays; // 1 = Mon, 7 = Sun (DateTime.monday .. DateTime.sunday)
  final bool reminderEnabled;

  const MedicineSchedule({
    required this.id,
    required this.medicineId,
    required this.hour,
    required this.minute,
    this.doseQuantity = 1.0,
    this.doseUnit = 'tablet',
    this.instruction,
    this.weekDays = const {1, 2, 3, 4, 5, 6, 7},
    this.reminderEnabled = true,
  });

  /// Formatted time string (e.g. "8:00 AM", "9:30 PM").
  String get formattedTime {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final p = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
  }

  MedicineSchedule copyWith({
    String? id,
    String? medicineId,
    int? hour,
    int? minute,
    double? doseQuantity,
    String? doseUnit,
    String? instruction,
    Set<int>? weekDays,
    bool? reminderEnabled,
  }) {
    return MedicineSchedule(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      doseQuantity: doseQuantity ?? this.doseQuantity,
      doseUnit: doseUnit ?? this.doseUnit,
      instruction: instruction ?? this.instruction,
      weekDays: weekDays ?? this.weekDays,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineSchedule &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
