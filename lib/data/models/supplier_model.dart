import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  final String? id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final double totalPurchases;
  final int totalProducts;
  final DateTime lastPurchaseDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const Supplier({
    this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.totalPurchases = 0.0,
    this.totalProducts = 0,
    required this.lastPurchaseDate,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  // Convert from JSON (API response)
  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] ?? json['_id'],
      name: json['name'] ?? '',
      contactPerson: json['contactPerson'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      totalPurchases: (json['totalPurchases'] ?? 0).toDouble(),
      totalProducts: json['totalProducts'] ?? 0,
      lastPurchaseDate: DateTime.parse(
        json['lastPurchaseDate'] ?? DateTime.now().toIso8601String(),
      ),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      createdBy: json['createdBy'] ?? '',
    );
  }

  // Convert to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      if (id != null && id!.isNotEmpty) 'id': id,
      'name': name,
      'contactPerson': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'totalPurchases': totalPurchases,
      'totalProducts': totalProducts,
      'lastPurchaseDate': lastPurchaseDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  // For creating new supplier (without ID and with current timestamps)
  factory Supplier.create({
    required String name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    required String createdBy,
  }) {
    final now = DateTime.now();
    return Supplier(
      name: name,
      contactPerson: contactPerson,
      phone: phone,
      email: email,
      address: address,
      lastPurchaseDate: now,
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy,
    );
  }

  // Convert to JSON for creating (excludes ID and uses current timestamps)
  Map<String, dynamic> toCreateJson() {
    final now = DateTime.now();
    return {
      'name': name,
      'contactPerson': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'totalPurchases': totalPurchases,
      'totalProducts': totalProducts,
      'lastPurchaseDate': now.toIso8601String(),
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  // Convert to JSON for updating (only includes modified fields)
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'contactPerson': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'totalPurchases': totalPurchases,
      'totalProducts': totalProducts,
      'lastPurchaseDate': lastPurchaseDate.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // For partial updates (PATCH requests)
  Map<String, dynamic> toPartialUpdateJson() {
    final jsonMap = <String, dynamic>{};

    if (name.isNotEmpty) jsonMap['name'] = name;
    if (contactPerson != null) jsonMap['contactPerson'] = contactPerson;
    if (phone != null) jsonMap['phone'] = phone;
    if (email != null) jsonMap['email'] = email;
    if (address != null) jsonMap['address'] = address;

    jsonMap['totalPurchases'] = totalPurchases;
    jsonMap['totalProducts'] = totalProducts;
    jsonMap['lastPurchaseDate'] = lastPurchaseDate.toIso8601String();
    jsonMap['updatedAt'] = DateTime.now().toIso8601String();

    return jsonMap;
  }

  Supplier copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    double? totalPurchases,
    int? totalProducts,
    DateTime? lastPurchaseDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalProducts: totalProducts ?? this.totalProducts,
      lastPurchaseDate: lastPurchaseDate ?? this.lastPurchaseDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  // Helper method to check if supplier is valid for creation
  bool get isValidForCreation {
    return name.isNotEmpty && createdBy.isNotEmpty;
  }

  // Helper method to check if supplier is valid for update
  bool get isValidForUpdate {
    return id != null && id!.isNotEmpty && name.isNotEmpty;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    contactPerson,
    phone,
    email,
    address,
    totalPurchases,
    totalProducts,
    lastPurchaseDate,
    createdAt,
    updatedAt,
    createdBy,
  ];
}
