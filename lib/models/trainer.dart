class Trainer {
  final int? id;
  final String name;
  final String? phone;
  final String? specialization;
  final String? createdAt;

  Trainer({
    this.id,
    required this.name,
    this.phone,
    this.specialization,
    this.createdAt,
  });

  factory Trainer.fromMap(Map<String, dynamic> map) {
    return Trainer(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      specialization: map['specialization'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'specialization': specialization,
      'created_at': createdAt,
    };
  }
}
