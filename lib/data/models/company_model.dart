import 'package:equatable/equatable.dart';
import 'user_role.dart';

/// Company model representing a tenant in the multi-tenant system
class Company extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? phone;
  final String? email;
  final String? address;
  final String? logoUrl;
  final String currency;
  final String? timezone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Company({
    required this.id,
    required this.name,
    this.description,
    this.phone,
    this.email,
    this.address,
    this.logoUrl,
    this.currency = 'BDT',
    this.timezone,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      logoUrl: json['logoUrl']?.toString(),
      currency: json['currency']?.toString() ?? 'BDT',
      timezone: json['timezone']?.toString(),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'phone': phone,
      'email': email,
      'address': address,
      'logoUrl': logoUrl,
      'currency': currency,
      'timezone': timezone,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Company copyWith({
    String? id,
    String? name,
    String? description,
    String? phone,
    String? email,
    String? address,
    String? logoUrl,
    String? currency,
    String? timezone,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      logoUrl: logoUrl ?? this.logoUrl,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    phone,
    email,
    address,
    logoUrl,
    currency,
    timezone,
    isActive,
    createdAt,
    updatedAt,
  ];
}

/// Company user model for team management
class CompanyUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final String? shopName;

  const CompanyUser({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    required this.role,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
    this.shopName,
  });

  factory CompanyUser.fromJson(Map<String, dynamic> json) {
    return CompanyUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: UserRole.fromString(json['role']?.toString()),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      isActive: json['isActive'] ?? true,
      shopName: json['shopName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      if (lastLoginAt != null) 'lastLoginAt': lastLoginAt!.toIso8601String(),
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    phone,
    role,
    createdAt,
    lastLoginAt,
    isActive,
  ];
}
