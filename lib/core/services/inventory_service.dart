import 'dart:io';
import 'package:shop_management/data/models/category_model.dart';
import 'package:shop_management/data/models/inventory_model.dart';
import 'package:shop_management/data/models/product_model.dart';
import 'package:shop_management/data/models/sale_model.dart';
import 'api_service.dart';

class InventoryService {
  /// Calculates inventory summary with a single pass through products
  static InventorySummary getInventorySummary(List<Product> products) {
    if (products.isEmpty) {
      return InventorySummary(
        totalProducts: 0,
        lowStockItems: 0,
        outOfStockItems: 0,
        totalStockValue: 0.0,
        totalInvestment: 0.0,
      );
    }

    var lowStock = 0;
    var outOfStock = 0;
    var stockValue = 0.0;
    var investment = 0.0;

    // Single pass through products - O(n) instead of multiple passes
    for (final p in products) {
      final stock = p.currentStock;

      if (stock == 0) {
        outOfStock++;
      } else if (p.isLowStock) {
        lowStock++;
      }

      stockValue += stock * p.sellingPrice;
      investment += stock * p.buyingPrice;
    }

    return InventorySummary(
      totalProducts: products.length,
      lowStockItems: lowStock,
      outOfStockItems: outOfStock,
      totalStockValue: stockValue,
      totalInvestment: investment,
    );
  }

  /// Gets stock alerts sorted by priority
  static List<StockAlert> getStockAlerts(List<Product> products) {
    final alerts = <StockAlert>[];

    for (final p in products) {
      final stock = p.currentStock;

      if (stock == 0) {
        alerts.add(
          StockAlert(
            productId: p.id!,
            productName: p.name,
            categoryName: p.categoryName ?? 'Unknown',
            currentStock: stock,
            minStockLevel: p.minStockLevel,
            alertType: 'out_of_stock',
          ),
        );
      } else if (p.isLowStock) {
        alerts.add(
          StockAlert(
            productId: p.id!,
            productName: p.name,
            categoryName: p.categoryName ?? 'Unknown',
            currentStock: stock,
            minStockLevel: p.minStockLevel,
            alertType: 'low_stock',
          ),
        );
      }
    }

    // Optimized sorting: out_of_stock first, then by stock level
    alerts.sort((a, b) {
      final aOutOfStock = a.alertType == 'out_of_stock';
      final bOutOfStock = b.alertType == 'out_of_stock';

      if (aOutOfStock && !bOutOfStock) return -1;
      if (!aOutOfStock && bOutOfStock) return 1;
      return a.currentStock.compareTo(b.currentStock);
    });

    return alerts;
  }

  /// Aggregates inventory data by category
  static List<CategoryInventory> getCategoryInventory(
    List<Product> products,
    List<Category> categories,
  ) {
    // Pre-populate map with categories
    final map = {
      for (final c in categories)
        c.id!: CategoryInventory(
          categoryId: c.id!,
          categoryName: c.name,
          productCount: 0,
          stockValue: 0.0,
          lowStockCount: 0,
        ),
    };

    // Single pass through products
    for (final p in products) {
      final categoryId = p.categoryId;
      if (!map.containsKey(categoryId)) continue;

      final current = map[categoryId]!;
      map[categoryId] = CategoryInventory(
        categoryId: current.categoryId,
        categoryName: current.categoryName,
        productCount: current.productCount + 1,
        stockValue: current.stockValue + (p.currentStock * p.sellingPrice),
        lowStockCount: current.lowStockCount + (p.isLowStock ? 1 : 0),
      );
    }

    // Convert to list and sort by stock value descending
    return map.values.toList()
      ..sort((a, b) => b.stockValue.compareTo(a.stockValue));
  }

  /// Returns products needing restock, sorted by urgency
  static List<Product> getProductsNeedingRestock(List<Product> products) {
    final needsRestock = products
        .where((p) => p.currentStock == 0 || p.isLowStock)
        .toList();

    needsRestock.sort((a, b) => a.currentStock.compareTo(b.currentStock));
    return needsRestock;
  }

  /// Calculates inventory turnover rate for a given period
  static double calculateInventoryTurnover(
    List<Sale> sales,
    List<Product> products,
    DateTime startDate,
    DateTime endDate,
  ) {
    if (sales.isEmpty || products.isEmpty) return 0.0;

    // Filter sales within date range
    final periodSales = sales.where(
      (s) => s.saleDate.isAfter(startDate) && s.saleDate.isBefore(endDate),
    );

    // Calculate total sales amount
    var totalSales = 0.0;
    for (final sale in periodSales) {
      totalSales += sale.totalAmount;
    }

    if (totalSales == 0.0) return 0.0;

    // Calculate average inventory value
    var totalInventoryValue = 0.0;
    for (final p in products) {
      totalInventoryValue += p.currentStock * p.buyingPrice;
    }

    final avgInventory = totalInventoryValue / products.length;
    return avgInventory > 0 ? totalSales / avgInventory : 0.0;
  }

  // ──────────────────────────────────────────────────────────────
  //  Network operations with proper error handling
  // ──────────────────────────────────────────────────────────────

  // Categories
  static Future<List<Category>> fetchCategories() async {
    try {
      final data = await ApiService.get('/categories');
      return (data as List).map((json) => Category.fromJson(json)).toList();
    } on ApiException catch (e) {
      _rethrowClean(e);
    }
  }

  static Future<Category> createCategory(String name) async {
    try {
      final data = await ApiService.post('/categories', {'name': name});
      return Category.fromJson(data);
    } on ApiException catch (e) {
      _rethrowClean(e);
    }
  }

  static Future<Category> updateCategory(String id, String name) async {
    try {
      final data = await ApiService.put('/categories/$id', {'name': name});
      return Category.fromJson(data);
    } on ApiException catch (e) {
      _rethrowClean(e);
    }
  }

  static Future<void> deleteCategory(String id) async {
    try {
      await ApiService.delete('/categories/$id');
    } on ApiException catch (e) {
      _rethrowClean(e);
    }
  }

  // Products
  static Future<List<Product>> fetchProducts() async {
    try {
      final data = await ApiService.get('/products');
      return (data as List).map((json) => Product.fromJson(json)).toList();
    } on ApiException catch (e) {
      _rethrowClean(e);
    }
  }

  static Future<Product> createProduct(Map<String, dynamic> productData) async {
    try {
      final data = await ApiService.post('/products', productData);
      return Product.fromJson(data);
    } on ApiException catch (e) {
      _rethrowClean(e);
    }
  }

  static Future<Product> updateProduct(
    String id,
    Map<String, dynamic> productData,
  ) async {
    try {
      final data = await ApiService.put('/products/$id', productData);
      return Product.fromJson(data);
    } on ApiException catch (e) {
      _rethrowClean(e);
    }
  }

  static Future<void> deleteProduct(String id) async {
    try {
      await ApiService.delete('/products/$id');
    } on ApiException catch (e) {
      _rethrowClean(e);
    }
  }

  static Future<Product> adjustStock({
    required String productId,
    required int quantity,
    required String reason,
  }) async {
    try {
      final payload = {
        'productId': productId,
        'quantity': quantity,
        'reason': reason,
      };
      final data = await ApiService.post('/inventory/adjust', payload);
      return Product.fromJson(data);
    } on ApiException catch (e) {
      _rethrowClean(e);
    }
  }

  // ──────────────────────────────────────────────────────────────
  //  Error handling
  // ──────────────────────────────────────────────────────────────

  static Never _rethrowClean(ApiException e) {
    final statusCode = e.statusCode;
    final originalMsg = e.message.toLowerCase();

    String msg;
    if (statusCode == 0) {
      msg = 'No internet connection.';
    } else if (statusCode >= 500) {
      msg = 'Server error. Please try again later.';
    } else if (originalMsg.contains('not found')) {
      msg = 'Item not found.';
    } else if (originalMsg.contains('already exists')) {
      msg = 'An item with this name already exists.';
    } else {
      msg = e.message;
    }

    throw Exception(msg);
  }
}
