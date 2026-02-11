import 'package:equatable/equatable.dart';

class Branch extends Equatable {
  final String id;
  final String name;
  final String companyId;
  final String? companyName;
  final String? address;
  final String? phone;
  final String? email;
  final bool isActive;
  final bool isMain;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Branch({
    required this.id,
    required this.name,
    required this.companyId,
    this.companyName,
    this.address,
    this.phone,
    this.email,
    this.isActive = true,
    this.isMain = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      companyId: json['company_id'] ?? json['companyId'] ?? '',
      companyName: json['company_name'] ?? json['companyName'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      isMain: json['is_main'] ?? json['isMain'] ?? false,
      createdAt: DateTime.parse(
        json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company_id': companyId,
      'company_name': companyName,
      'address': address,
      'phone': phone,
      'email': email,
      'is_active': isActive,
      'is_main': isMain,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (email != null && email!.isNotEmpty) 'email': email,
      'is_main': isMain,
    };
  }

  Branch copyWith({
    String? id,
    String? name,
    String? companyId,
    String? companyName,
    String? address,
    String? phone,
    String? email,
    bool? isActive,
    bool? isMain,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Branch(
      id: id ?? this.id,
      name: name ?? this.name,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      isMain: isMain ?? this.isMain,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        companyId,
        companyName,
        address,
        phone,
        email,
        isActive,
        isMain,
        createdAt,
        updatedAt,
      ];
}
