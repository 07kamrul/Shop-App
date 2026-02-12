import 'package:equatable/equatable.dart';
import 'user_role.dart';

/// Company model representing a tenant in the multi-tenant system
class Company extends Equatable {
  final String id;
  final String name;
  final String? businessType;
  final String? description;
  final String? phone;
  final String? email;
  final String? address;
  final String? logoUrl;
  final String currency;
  final String? country;
  final String? timezone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Company({
    required this.id,
    required this.name,
    this.businessType,
    this.description,
    this.phone,
    this.email,
    this.address,
    this.logoUrl,
    this.currency = 'BDT',
    this.country,
    this.timezone,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      businessType: json['business_type']?.toString() ?? json['businessType']?.toString(),
      description: json['description']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      logoUrl: json['logo_url']?.toString() ?? json['logoUrl']?.toString(),
      currency: json['currency']?.toString() ?? 'BDT',
      country: json['country']?.toString(),
      timezone: json['timezone']?.toString(),
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdAt: DateTime.parse(
        json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: (json['updated_at'] ?? json['updatedAt']) != null
          ? DateTime.parse(json['updated_at'] ?? json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (businessType != null) 'business_type': businessType,
      'description': description,
      'phone': phone,
      'email': email,
      'address': address,
      'logo_url': logoUrl,
      'currency': currency,
      if (country != null) 'country': country,
      'timezone': timezone,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  Company copyWith({
    String? id,
    String? name,
    String? businessType,
    String? description,
    String? phone,
    String? email,
    String? address,
    String? logoUrl,
    String? currency,
    String? country,
    String? timezone,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      businessType: businessType ?? this.businessType,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      logoUrl: logoUrl ?? this.logoUrl,
      currency: currency ?? this.currency,
      country: country ?? this.country,
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
    businessType,
    description,
    phone,
    email,
    address,
    logoUrl,
    currency,
    country,
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
