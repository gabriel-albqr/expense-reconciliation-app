/// Represents a payment method (card/account) used in purchases.
class PaymentSource {
  PaymentSource({required this.id, required this.name, required this.ownerId});

  final String id;
  final String name;
  final String ownerId;

  @override
  String toString() {
    return 'PaymentSource(id: $id, name: $name, ownerId: $ownerId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is PaymentSource &&
        other.id == id &&
        other.name == name &&
        other.ownerId == ownerId;
  }

  @override
  int get hashCode => Object.hash(id, name, ownerId);
}
