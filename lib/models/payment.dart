class Payment {
  final int? id;
  final int subscriptionId;
  final double amount;
  final String paymentDate;
  final String? paymentMethod;
  final String? note;

  Payment({
    this.id,
    required this.subscriptionId,
    required this.amount,
    required this.paymentDate,
    this.paymentMethod,
    this.note,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      subscriptionId: map['subscription_id'],
      amount: map['amount'],
      paymentDate: map['payment_date'],
      paymentMethod: map['payment_method'],
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subscription_id': subscriptionId,
      'amount': amount,
      'payment_date': paymentDate,
      'payment_method': paymentMethod,
      'note': note,
    };
  }
}
