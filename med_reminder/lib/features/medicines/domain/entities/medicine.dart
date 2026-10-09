/// Available dosage forms for medicine.
enum MedicineForm {
  tablet,
  capsule,
  syrup,
  drops,
  injection,
  inhaler,
  other;

  String get displayName {
    switch (this) {
      case MedicineForm.tablet:
        return 'Tablet';
      case MedicineForm.capsule:
        return 'Capsule';
      case MedicineForm.syrup:
        return 'Syrup';
      case MedicineForm.drops:
        return 'Drops';
      case MedicineForm.injection:
        return 'Injection';
      case MedicineForm.inhaler:
        return 'Inhaler';
      case MedicineForm.other:
        return 'Other';
    }
  }

  static MedicineForm fromString(String value) {
    return MedicineForm.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => MedicineForm.tablet,
    );
  }
}

/// Pure domain entity representing a Medicine in MediCare.
class Medicine {
  final String id;
  final String name;
  final String? strength; // e.g. "500mg"
  final MedicineForm form;
  final String? category; // e.g. "Diabetes", "Hypertension"
  final double totalQuantity;
  final double remainingQuantity;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final double refillThreshold; // e.g. 5 tablets
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Medicine({
    required this.id,
    required this.name,
    this.strength,
    required this.form,
    this.category,
    required this.totalQuantity,
    required this.remainingQuantity,
    required this.startDate,
    this.endDate,
    this.notes,
    this.refillThreshold = 5.0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isRunningLow => remainingQuantity <= refillThreshold;
  bool get isOutOfStock => remainingQuantity <= 0;

  Medicine copyWith({
    String? id,
    String? name,
    String? strength,
    MedicineForm? form,
    String? category,
    double? totalQuantity,
    double? remainingQuantity,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    double? refillThreshold,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      strength: strength ?? this.strength,
      form: form ?? this.form,
      category: category ?? this.category,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      refillThreshold: refillThreshold ?? this.refillThreshold,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Medicine && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
