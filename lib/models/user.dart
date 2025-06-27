class User {
  final int? id;
  final String username;
  final String? email;
  final String password;
  final String role;
  final String? createdAt;

  User({
    this.id,
    required this.username,
    this.email,
    required this.password,
    this.role = 'staff',
    this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'role': role,
      'created_at': createdAt,
    };
  }
}
