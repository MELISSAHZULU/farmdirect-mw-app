class User {
  final int id;
  final String phone;
  final String firstName;
  final String lastName;
  final String? email;
  final String? area;
  final String? role;

  User({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.email,
    this.area,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phone: json['phone'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'],
      area: json['area'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'area': area,
      'role': role,
    };
  }
}
