import 'package:equatable/equatable.dart';

class SaleItem extends Equatable {
  final String productId;
  final String productName;
  final int quantity;
  final double unitBuyingPrice;
  final double unitSellingPrice;

  const SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitBuyingPrice,
    required this.unitSellingPrice,
  });

  double get totalAmount => quantity * unitSellingPrice;
  double get totalCost => quantity * unitBuyingPrice;
  double get totalProfit => totalAmount - totalCost;

  // Convert to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitBuyingPrice': unitBuyingPrice,
      'unitSellingPrice': unitSellingPrice,
      'totalAmount': totalAmount,
      'totalCost': totalCost,
      'totalProfit': totalProfit,
    };
  }

  // Convert from JSON (API response)
  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitBuyingPrice: (json['unitBuyingPrice'] ?? 0).toDouble(),
      unitSellingPrice: (json['unitSellingPrice'] ?? 0).toDouble(),
    );
  }

  SaleItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? unitBuyingPrice,
    double? unitSellingPrice,
  }) {
    return SaleItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitBuyingPrice: unitBuyingPrice ?? this.unitBuyingPrice,
      unitSellingPrice: unitSellingPrice ?? this.unitSellingPrice,
    );
  }

  @override
  List<Object?> get props => [
    productId,
    productName,
    quantity,
    unitBuyingPrice,
    unitSellingPrice,
  ];
}

class Sale extends Equatable {
  final String? id;
  final DateTime dateTime;
  final DateTime updatedAt;
  final List<SaleItem> items;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String paymentMethod;
  final double totalAmount;
  final double totalCost;
  final double totalProfit;
  final String createdBy;
  final String? invoiceNumber;
  final String? notes;

  const Sale({
    this.id,
    required this.dateTime,
    required this.updatedAt,
    required this.items,
    this.customerId,
    this.customerName,
    this.customerPhone,
    required this.paymentMethod,
    required this.totalAmount,
    required this.totalCost,
    required this.totalProfit,
    required this.createdBy,
    this.invoiceNumber,
    this.notes,
  });

  // Convert from JSON (API response)
  factory Sale.fromJson(Map<String, dynamic> json) {
    final items =
        (json['items'] as List<dynamic>?)
            ?.map((item) => SaleItem.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return Sale(
      id: json['id'] ?? json['_id'],
      dateTime: DateTime.parse(
        json['dateTime'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      items: items,
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      paymentMethod: json['paymentMethod'] ?? 'cash',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      totalProfit: (json['totalProfit'] ?? 0).toDouble(),
      createdBy: json['createdBy'] ?? '',
      invoiceNumber: json['invoiceNumber'],
      notes: json['notes'],
    );
  }

  // Convert to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      if (id != null && id!.isNotEmpty) 'id': id,
      'dateTime': dateTime.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'customerName': customerName,
      'customerPhone': customerPhone,
      'paymentMethod': paymentMethod,
      'totalAmount': totalAmount,
      'totalCost': totalCost,
      'totalProfit': totalProfit,
      'createdBy': createdBy,
      'invoiceNumber': invoiceNumber,
      'notes': notes,
    };
  }

  // Factory for creating new sales
  factory Sale.create({
    required List<SaleItem> items,
    String? customerName,
    String? customerPhone,
    required String paymentMethod,
    required String createdBy,
    String? invoiceNumber,
    String? notes,
  }) {
    final now = DateTime.now();

    // Calculate totals
    final totalAmount = items.fold(0.0, (sum, item) => sum + item.totalAmount);
    final totalCost = items.fold(0.0, (sum, item) => sum + item.totalCost);
    final totalProfit = items.fold(0.0, (sum, item) => sum + item.totalProfit);

    return Sale(
      dateTime: now,
      updatedAt: now,
      items: items,
      customerName: customerName,
      customerPhone: customerPhone,
      paymentMethod: paymentMethod,
      totalAmount: totalAmount,
      totalCost: totalCost,
      totalProfit: totalProfit,
      createdBy: createdBy,
      invoiceNumber: invoiceNumber,
      notes: notes,
    );
  }

  // Convert to JSON for creating new sale
  Map<String, dynamic> toCreateJson() {
    final now = DateTime.now();

    return {
      'dateTime': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'customerName': customerName,
      'customerPhone': customerPhone,
      'paymentMethod': paymentMethod,
      'totalAmount': totalAmount,
      'totalCost': totalCost,
      'totalProfit': totalProfit,
      'createdBy': createdBy,
      'invoiceNumber': invoiceNumber,
      'notes': notes,
    };
  }

  // Convert to JSON for updating sale
  Map<String, dynamic> toUpdateJson() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'customerName': customerName,
      'customerPhone': customerPhone,
      'paymentMethod': paymentMethod,
      'totalAmount': totalAmount,
      'totalCost': totalCost,
      'totalProfit': totalProfit,
      'invoiceNumber': invoiceNumber,
      'notes': notes,
    };
  }

  // Helper methods
  bool get isValidForCreation {
    return items.isNotEmpty &&
        paymentMethod.isNotEmpty &&
        createdBy.isNotEmpty &&
        totalAmount > 0;
  }

  bool get isValidForUpdate {
    return id != null && id!.isNotEmpty && isValidForCreation;
  }

  // Get item count
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  // Find item by product ID
  SaleItem? findItemByProductId(String productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  Sale copyWith({
    String? id,
    DateTime? dateTime,
    DateTime? updatedAt,
    List<SaleItem>? items,
    String? customerName,
    String? customerPhone,
    String? paymentMethod,
    double? totalAmount,
    double? totalCost,
    double? totalProfit,
    String? createdBy,
    String? invoiceNumber,
    String? notes,
  }) {
    return Sale(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      totalAmount: totalAmount ?? this.totalAmount,
      totalCost: totalCost ?? this.totalCost,
      totalProfit: totalProfit ?? this.totalProfit,
      createdBy: createdBy ?? this.createdBy,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    dateTime,
    updatedAt,
    items,
    customerName,
    customerPhone,
    paymentMethod,
    totalAmount,
    totalCost,
    totalProfit,
    createdBy,
    invoiceNumber,
    notes,
  ];
}
