class UserModel {
  final String id;
  final String email;
  final String role;
  final String? legalName;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.legalName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      legalName: json['legalName'],
    );
  }
}
