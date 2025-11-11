import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String? id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final double totalPurchases;
  final int totalTransactions;
  final DateTime lastPurchaseDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? customerType;
  final double? creditBalance;
  final bool isActive;

  const Customer({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.totalPurchases = 0.0,
    this.totalTransactions = 0,
    required this.lastPurchaseDate,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.customerType,
    this.creditBalance,
    this.isActive = true,
  });

  // Convert from JSON (API response)
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? json['_id'],
      name: json['name'] ?? '',
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      totalPurchases: (json['totalPurchases'] ?? 0).toDouble(),
      totalTransactions: json['totalTransactions'] ?? 0,
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
      customerType: json['customerType'] ?? 'regular',
      creditBalance: (json['creditBalance'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
    );
  }

  // Convert to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      if (id != null && id!.isNotEmpty) 'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'totalPurchases': totalPurchases,
      'totalTransactions': totalTransactions,
      'lastPurchaseDate': lastPurchaseDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'customerType': customerType,
      'creditBalance': creditBalance,
      'isActive': isActive,
    };
  }

  // Factory for creating new customers
  factory Customer.create({
    required String name,
    String? phone,
    String? email,
    String? address,
    required String createdBy,
    String? customerType,
    double? creditBalance,
  }) {
    final now = DateTime.now();
    return Customer(
      name: name,
      phone: phone,
      email: email,
      address: address,
      lastPurchaseDate: now,
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy,
      customerType: customerType ?? 'regular',
      creditBalance: creditBalance ?? 0.0,
      isActive: true,
    );
  }

  // Convert to JSON for creating new customer
  Map<String, dynamic> toCreateJson() {
    final now = DateTime.now();
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'totalPurchases': totalPurchases,
      'totalTransactions': totalTransactions,
      'lastPurchaseDate': now.toIso8601String(),
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'createdBy': createdBy,
      'customerType': customerType,
      'creditBalance': creditBalance,
      'isActive': isActive,
    };
  }

  // Convert to JSON for updating customer
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'totalPurchases': totalPurchases,
      'totalTransactions': totalTransactions,
      'lastPurchaseDate': lastPurchaseDate.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'customerType': customerType,
      'creditBalance': creditBalance,
      'isActive': isActive,
    };
  }

  // For partial updates (PATCH requests)
  Map<String, dynamic> toPartialUpdateJson() {
    final jsonMap = <String, dynamic>{};

    if (name.isNotEmpty) jsonMap['name'] = name;
    if (phone != null) jsonMap['phone'] = phone;
    if (email != null) jsonMap['email'] = email;
    if (address != null) jsonMap['address'] = address;

    jsonMap['totalPurchases'] = totalPurchases;
    jsonMap['totalTransactions'] = totalTransactions;
    jsonMap['lastPurchaseDate'] = lastPurchaseDate.toIso8601String();
    jsonMap['updatedAt'] = DateTime.now().toIso8601String();

    if (customerType != null) jsonMap['customerType'] = customerType;
    if (creditBalance != null) jsonMap['creditBalance'] = creditBalance;

    jsonMap['isActive'] = isActive;

    return jsonMap;
  }

  // For updating purchase statistics only
  Map<String, dynamic> toPurchaseUpdateJson({required double purchaseAmount}) {
    return {
      'totalPurchases': totalPurchases + purchaseAmount,
      'totalTransactions': totalTransactions + 1,
      'lastPurchaseDate': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // For updating credit balance only
  Map<String, dynamic> toCreditUpdateJson() {
    return {
      'creditBalance': creditBalance,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Business logic methods
  double get averagePurchaseValue =>
      totalTransactions > 0 ? totalPurchases / totalTransactions : 0.0;

  bool get isRegularCustomer => customerType == 'regular';

  bool get isVIPCustomer => customerType == 'vip';

  bool get hasCredit => (creditBalance ?? 0) > 0;

  bool get hasOutstandingBalance => (creditBalance ?? 0) < 0;

  // Validation methods
  bool get isValidForCreation {
    return name.isNotEmpty && createdBy.isNotEmpty;
  }

  bool get isValidForUpdate {
    return id != null && id!.isNotEmpty && name.isNotEmpty;
  }

  bool get hasValidContactInfo {
    return phone != null && phone!.isNotEmpty ||
        email != null && email!.isNotEmpty;
  }

  // Update methods
  Customer addPurchase(double amount) {
    return copyWith(
      totalPurchases: totalPurchases + amount,
      totalTransactions: totalTransactions + 1,
      lastPurchaseDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Customer updateCredit(double newBalance) {
    return copyWith(creditBalance: newBalance, updatedAt: DateTime.now());
  }

  Customer markAsVIP() {
    return copyWith(customerType: 'vip', updatedAt: DateTime.now());
  }

  Customer markAsRegular() {
    return copyWith(customerType: 'regular', updatedAt: DateTime.now());
  }

  Customer deactivate() {
    return copyWith(isActive: false, updatedAt: DateTime.now());
  }

  Customer activate() {
    return copyWith(isActive: true, updatedAt: DateTime.now());
  }

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    double? totalPurchases,
    int? totalTransactions,
    DateTime? lastPurchaseDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? customerType,
    double? creditBalance,
    bool? isActive,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      lastPurchaseDate: lastPurchaseDate ?? this.lastPurchaseDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      customerType: customerType ?? this.customerType,
      creditBalance: creditBalance ?? this.creditBalance,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    email,
    address,
    totalPurchases,
    totalTransactions,
    lastPurchaseDate,
    createdAt,
    updatedAt,
    createdBy,
    customerType,
    creditBalance,
    isActive,
  ];
}
