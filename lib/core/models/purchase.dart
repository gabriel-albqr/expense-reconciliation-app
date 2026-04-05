/// Represents a purchase transaction recorded in the system.
class Purchase {
  Purchase({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.paymentSourceId,
    this.installmentNumber,
    this.totalInstallments,
    this.notes,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String paymentSourceId;
  final int? installmentNumber;
  final int? totalInstallments;
  final String? notes;

  @override
  String toString() {
    return 'Purchase('
        'id: $id, '
        'title: $title, '
        'amount: $amount, '
        'date: $date, '
        'paymentSourceId: $paymentSourceId, '
        'installmentNumber: $installmentNumber, '
        'totalInstallments: $totalInstallments, '
        'notes: $notes'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Purchase &&
        other.id == id &&
        other.title == title &&
        other.amount == amount &&
        other.date == date &&
        other.paymentSourceId == paymentSourceId &&
        other.installmentNumber == installmentNumber &&
        other.totalInstallments == totalInstallments &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      amount,
      date,
      paymentSourceId,
      installmentNumber,
      totalInstallments,
      notes,
    );
  }
}
