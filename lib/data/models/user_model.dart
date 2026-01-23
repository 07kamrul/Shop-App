import 'package:equatable/equatable.dart';
import 'user_role.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? companyId;
  final String? companyName;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;

  // Legacy field - kept for backwards compatibility
  String get shopName => companyName ?? '';

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.companyId,
    this.companyName,
    this.role = UserRole.staff,
    required this.createdAt,
    required this.updatedAt,
    required this.isEmailVerified,
  });

  // Permission helpers
  bool get isOwner => role.isOwner;
  bool get isManagerOrAbove => role.isManagerOrAbove;
  bool get canManageCompany => role.canManageCompany;
  bool get canManageUsers => role.canManageUsers;
  bool get canViewTeam => role.canViewTeam;
  bool get canViewReports => role.canViewReports;

  // Convert from JSON (API response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      companyId: json['companyId'],
      companyName: json['companyName'] ?? json['shopName'] ?? '',
      role: UserRole.fromString(json['role']?.toString()),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      isEmailVerified: json['isEmailVerified'] ?? false,
    );
  }

  // Convert to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'companyId': companyId,
      'companyName': companyName,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
    };
  }

  // For creating new user (without ID)
  Map<String, dynamic> toCreateJson() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'companyName': companyName,
      'isEmailVerified': isEmailVerified,
    };
  }

  // For updating user (only included fields)
  Map<String, dynamic> toUpdateJson() {
    return {
      if (email.isNotEmpty) 'email': email,
      if (name.isNotEmpty) 'name': name,
      'phone': phone,
      'isEmailVerified': isEmailVerified,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? companyId,
    String? companyName,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phone,
        companyId,
        companyName,
        role,
        createdAt,
        updatedAt,
        isEmailVerified,
      ];
}
