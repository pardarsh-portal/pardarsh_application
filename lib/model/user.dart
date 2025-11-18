class UserModel {
  final String id;
  final String email;
  final String role;
  final String? legalName;
  final String? phone;
  final bool isActive;
  final DateTime? createdAt;

  // Additional properties for contractor ratings
  double? averageRating;
  int? totalReviews;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.legalName,
    this.phone,
    this.isActive = true,
    this.createdAt,
    this.averageRating,
    this.totalReviews,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      legalName: json['legalName'],
      phone: json['phone'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      averageRating: json['averageRating']?.toDouble(),
      totalReviews: json['totalReviews'],
    );
  }

  // Helper methods for role checking
  bool get isContractor => role.toLowerCase() == 'contractor';
  bool get isGovernmentOfficial =>
      role.toLowerCase() == 'government' ||
      role.toLowerCase() == 'government official';
  bool get isGeneralUser =>
      role.toLowerCase() == 'general user' || role.toLowerCase() == 'user';

  String get displayRole {
    switch (role.toLowerCase()) {
      case 'contractor':
        return 'Contractor';
      case 'government':
      case 'government official':
        return 'Government Official';
      case 'general user':
      case 'user':
        return 'General User';
      default:
        return role;
    }
  }
}
