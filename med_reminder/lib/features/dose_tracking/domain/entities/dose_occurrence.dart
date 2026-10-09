import 'package:flutter_application_2/features/medicines/domain/entities/medicine.dart';

/// The execution status of a scheduled medicine dose.
enum DoseStatus {
  pending,
  taken,
  skipped,
  missed;

  String get displayName {
    switch (this) {
      case DoseStatus.pending:
        return 'Pending';
      case DoseStatus.taken:
        return 'Taken';
      case DoseStatus.skipped:
        return 'Skipped';
      case DoseStatus.missed:
        return 'Missed';
    }
  }
}

/// Pure domain entity representing a single dose scheduled at a specific point in time.
class DoseOccurrence {
  final String id;
  final String medicineId;
  final String scheduleId;
  final String medicineName;
  final String? strength;
  final MedicineForm form;
  final String? instruction;
  final DateTime scheduledAtUtc;
  final DoseStatus status;
  final DateTime? actionAtUtc;
  final double plannedQuantity;
  final String doseUnit;

  const DoseOccurrence({
    required this.id,
    required this.medicineId,
    required this.scheduleId,
    required this.medicineName,
    this.strength,
    required this.form,
    this.instruction,
    required this.scheduledAtUtc,
    this.status = DoseStatus.pending,
    this.actionAtUtc,
    this.plannedQuantity = 1.0,
    this.doseUnit = 'tablet',
  });

  /// The scheduled time converted to the device's local timezone.
  DateTime get scheduledAtLocal => scheduledAtUtc.toLocal();

  /// Formatted scheduled time string (e.g., "8:00 AM").
  String get formattedTime {
    final local = scheduledAtLocal;
    final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = local.minute.toString().padLeft(2, '0');
    final p = local.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
  }

  /// Calculates the effective status dynamically.
  /// If the dose was not marked taken or skipped and the grace period (default 2h) has passed,
  /// it is considered 'missed'.
  DoseStatus effectiveStatus(DateTime now, {Duration gracePeriod = const Duration(hours: 2)}) {
    if (status == DoseStatus.taken) return DoseStatus.taken;
    if (status == DoseStatus.skipped) return DoseStatus.skipped;
    if (status == DoseStatus.missed) return DoseStatus.missed;

    final cutoff = scheduledAtLocal.add(gracePeriod);
    if (now.isAfter(cutoff)) {
      return DoseStatus.missed;
    }
    return DoseStatus.pending;
  }

  DoseOccurrence copyWith({
    String? id,
    String? medicineId,
    String? scheduleId,
    String? medicineName,
    String? strength,
    MedicineForm? form,
    String? instruction,
    DateTime? scheduledAtUtc,
    DoseStatus? status,
    DateTime? actionAtUtc,
    double? plannedQuantity,
    String? doseUnit,
  }) {
    return DoseOccurrence(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      scheduleId: scheduleId ?? this.scheduleId,
      medicineName: medicineName ?? this.medicineName,
      strength: strength ?? this.strength,
      form: form ?? this.form,
      instruction: instruction ?? this.instruction,
      scheduledAtUtc: scheduledAtUtc ?? this.scheduledAtUtc,
      status: status ?? this.status,
      actionAtUtc: actionAtUtc ?? this.actionAtUtc,
      plannedQuantity: plannedQuantity ?? this.plannedQuantity,
      doseUnit: doseUnit ?? this.doseUnit,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoseOccurrence &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
