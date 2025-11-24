import 'package:equatable/equatable.dart';

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

  @override
  List<Object?> get props => [
    totalProducts,
    lowStockItems,
    outOfStockItems,
    totalStockValue,
    totalInvestment,
  ];
}

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

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    productCount,
    stockValue,
    lowStockCount,
  ];
}
