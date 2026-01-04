class AdminUser {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String role;
  final bool isBanned;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  AdminUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.role,
    required this.isBanned,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString(),
      role: json['role']?.toString() ?? '',
      isBanned: json['isBanned'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'].toString())
          : null,
    );
  }
}

