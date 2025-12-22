// data/models/inventory_model.dart

import 'package:equatable/equatable.dart';

/// Represents the overall inventory summary
class InventorySummary extends Equatable {
  final int totalProducts;
  final int lowStockItems;
  final int outOfStockItems;
  final double totalStockValue;
  final double totalInvestment;

  const InventorySummary({
    required this.totalProducts,
    required this.lowStockItems,
    required this.outOfStockItems,
    required this.totalStockValue,
    required this.totalInvestment,
  });

  factory InventorySummary.fromJson(Map<String, dynamic> json) {
    return InventorySummary(
      totalProducts: json['totalProducts'] as int,
      lowStockItems: json['lowStockItems'] as int,
      outOfStockItems: json['outOfStockItems'] as int,
      totalStockValue: (json['totalStockValue'] as num).toDouble(),
      totalInvestment: (json['totalInvestment'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    totalProducts,
    lowStockItems,
    outOfStockItems,
    totalStockValue,
    totalInvestment,
  ];
}

/// Represents a single stock alert (low or out of stock)
class StockAlert extends Equatable {
  final String productId;
  final String productName;
  final String categoryName;
  final int currentStock;
  final int minStockLevel;
  final String alertType; // 'low_stock' or 'out_of_stock'

  const StockAlert({
    required this.productId,
    required this.productName,
    required this.categoryName,
    required this.currentStock,
    required this.minStockLevel,
    required this.alertType,
  });

  factory StockAlert.fromJson(Map<String, dynamic> json) {
    return StockAlert(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      categoryName: (json['categoryName'] as String?) ?? 'Unknown',
      currentStock: json['currentStock'] as int,
      minStockLevel: json['minStockLevel'] as int,
      alertType: json['alertType'] as String,
    );
  }

  bool get isOutOfStock => alertType == 'out_of_stock';
  bool get isLowStock => alertType == 'low_stock';

  @override
  List<Object?> get props => [
    productId,
    productName,
    categoryName,
    currentStock,
    minStockLevel,
    alertType,
  ];
}

/// Represents inventory aggregated by category
class CategoryInventory extends Equatable {
  final String categoryId;
  final String categoryName;
  final int productCount;
  final double stockValue;
  final int lowStockCount;

  const CategoryInventory({
    required this.categoryId,
    required this.categoryName,
    required this.productCount,
    required this.stockValue,
    required this.lowStockCount,
  });

  factory CategoryInventory.fromJson(Map<String, dynamic> json) {
    return CategoryInventory(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      productCount: json['productCount'] as int,
      stockValue: (json['stockValue'] as num).toDouble(),
      lowStockCount: json['lowStockCount'] as int,
    );
  }

  double get averageValuePerProduct =>
      productCount > 0 ? stockValue / productCount : 0.0;

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    productCount,
    stockValue,
    lowStockCount,
  ];
}
