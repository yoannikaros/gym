class MembershipPackage {
  final int? id;
  final String name;
  final int durationDays;
  final double price;
  final String? description;
  final String? createdAt;

  MembershipPackage({
    this.id,
    required this.name,
    required this.durationDays,
    required this.price,
    this.description,
    this.createdAt,
  });

  factory MembershipPackage.fromMap(Map<String, dynamic> map) {
    return MembershipPackage(
      id: map['id'],
      name: map['name'],
      durationDays: map['duration_days'],
      price: map['price'],
      description: map['description'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'duration_days': durationDays,
      'price': price,
      'description': description,
      'created_at': createdAt,
    };
  }
}
