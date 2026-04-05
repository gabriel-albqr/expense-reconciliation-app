/// Represents how a purchase amount is split for a specific person.
class PurchaseSplit {
  PurchaseSplit({
    required this.id,
    required this.purchaseId,
    required this.personId,
    required this.amount,
  });

  final String id;
  final String purchaseId;
  final String personId;
  final double amount;

  @override
  String toString() {
    return 'PurchaseSplit('
        'id: $id, '
        'purchaseId: $purchaseId, '
        'personId: $personId, '
        'amount: $amount'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is PurchaseSplit &&
        other.id == id &&
        other.purchaseId == purchaseId &&
        other.personId == personId &&
        other.amount == amount;
  }

  @override
  int get hashCode => Object.hash(id, purchaseId, personId, amount);
}
