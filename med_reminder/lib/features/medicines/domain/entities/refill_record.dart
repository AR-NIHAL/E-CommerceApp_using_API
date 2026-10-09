/// Pure domain entity tracking a refill event for inventory auditing.
class RefillRecord {
  final String id;
  final String medicineId;
  final double addedQuantity;
  final DateTime refilledAt;

  const RefillRecord({
    required this.id,
    required this.medicineId,
    required this.addedQuantity,
    required this.refilledAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefillRecord &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
