import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String shopName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    required this.shopName,
    required this.createdAt,
    required this.updatedAt,
    required this.isEmailVerified,
  });

  // Convert from JSON (API response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      shopName: json['shopName'] ?? '',
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
      'shopName': shopName,
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
      'shopName': shopName,
      'isEmailVerified': isEmailVerified,
    };
  }

  // For updating user (only included fields)
  Map<String, dynamic> toUpdateJson() {
    return {
      if (email.isNotEmpty) 'email': email,
      if (name.isNotEmpty) 'name': name,
      'phone': phone,
      if (shopName.isNotEmpty) 'shopName': shopName,
      'isEmailVerified': isEmailVerified,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? shopName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      shopName: shopName ?? this.shopName,
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
    shopName,
    createdAt,
    updatedAt,
    isEmailVerified,
  ];
}
