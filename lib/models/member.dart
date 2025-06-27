class Member {
  final int? id;
  final int? userId;
  final String name;
  final String? gender;
  final String? birthDate;
  final String? phone;
  final String? email;
  final String? address;
  final String? joinDate;
  final String status;
  final String? createdAt;

  Member({
    this.id,
    this.userId,
    required this.name,
    this.gender,
    this.birthDate,
    this.phone,
    this.email,
    this.address,
    this.joinDate,
    this.status = 'active',
    this.createdAt,
  });

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      gender: map['gender'],
      birthDate: map['birth_date'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      joinDate: map['join_date'],
      status: map['status'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'gender': gender,
      'birth_date': birthDate,
      'phone': phone,
      'email': email,
      'address': address,
      'join_date': joinDate,
      'status': status,
      'created_at': createdAt,
    };
  }
}
