import 'package:equatable/equatable.dart';
import 'user_role.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? companyId;
  final String? companyName;
  final String? branchId;
  final String? branchName;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final bool hasCompany;
  final bool hasBranch;
  final bool isApproved;

  // Legacy field - kept for backwards compatibility
  String get shopName => companyName ?? '';

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.companyId,
    this.companyName,
    this.branchId,
    this.branchName,
    this.role = UserRole.staff,
    required this.createdAt,
    required this.updatedAt,
    required this.isEmailVerified,
    this.hasCompany = false,
    this.hasBranch = false,
    this.isApproved = false,
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
      companyId: json['company_id'] ?? json['companyId'],
      companyName: json['company_name'] ?? json['companyName'] ?? json['shopName'] ?? '',
      branchId: json['branch_id'] ?? json['branchId'],
      branchName: json['branch_name'] ?? json['branchName'],
      role: UserRole.fromString(json['role']?.toString()),
      createdAt: DateTime.parse(
        json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      isEmailVerified: json['isEmailVerified'] ?? json['is_email_verified'] ?? false,
      hasCompany: json['has_company'] ?? json['hasCompany'] ?? false,
      hasBranch: json['has_branch'] ?? json['hasBranch'] ?? false,
      isApproved: json['is_approved'] ?? json['isApproved'] ?? false,
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
    String? branchId,
    String? branchName,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    bool? hasCompany,
    bool? hasBranch,
    bool? isApproved,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      hasCompany: hasCompany ?? this.hasCompany,
      hasBranch: hasBranch ?? this.hasBranch,
      isApproved: isApproved ?? this.isApproved,
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
        branchId,
        branchName,
        role,
        createdAt,
        updatedAt,
        isEmailVerified,
        hasCompany,
        hasBranch,
        isApproved,
      ];
}
