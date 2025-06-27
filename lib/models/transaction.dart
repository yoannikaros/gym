class Transaction {
  final int? id;
  final String type;
  final String? category;
  final double amount;
  final String? description;
  final String transactionDate;
  final String? createdAt;

  Transaction({
    this.id,
    required this.type,
    this.category,
    required this.amount,
    this.description,
    required this.transactionDate,
    this.createdAt,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      type: map['type'],
      category: map['category'],
      amount: map['amount'],
      description: map['description'],
      transactionDate: map['transaction_date'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'amount': amount,
      'description': description,
      'transaction_date': transactionDate,
      'created_at': createdAt,
    };
  }
}
