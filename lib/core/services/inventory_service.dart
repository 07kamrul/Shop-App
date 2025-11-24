import 'package:shop_management/data/models/category_model.dart';
import 'package:shop_management/data/models/inventory_model.dart';
import 'package:shop_management/data/models/product_model.dart';
import 'package:shop_management/data/models/sale_model.dart';

class InventoryService {
  // Get inventory summary
  InventorySummary getInventorySummary(List<Product> products) {
    final totalProducts = products.length;
    final lowStockItems = products
        .where((p) => p.isLowStock && p.currentStock > 0)
        .length;
    final outOfStockItems = products.where((p) => p.currentStock == 0).length;

    final totalStockValue = products.fold(0.0, (sum, product) {
      return sum + (product.currentStock * product.sellingPrice);
    });

    final totalInvestment = products.fold(0.0, (sum, product) {
      return sum + (product.currentStock * product.buyingPrice);
    });

    return InventorySummary(
      totalProducts: totalProducts,
      lowStockItems: lowStockItems,
      outOfStockItems: outOfStockItems,
      totalStockValue: totalStockValue,
      totalInvestment: totalInvestment,
    );
  }

  // Get stock alerts
  List<StockAlert> getStockAlerts(List<Product> products) {
    final alerts = <StockAlert>[];

    for (final product in products) {
      if (product.currentStock == 0) {
        alerts.add(
          StockAlert(
            productId: product.id!,
            productName: product.name,
            categoryName: 'Unknown', // You might want to fetch category name
            currentStock: product.currentStock,
            minStockLevel: product.minStockLevel,
            alertType: 'out_of_stock',
          ),
        );
      } else if (product.isLowStock) {
        alerts.add(
          StockAlert(
            productId: product.id!,
            productName: product.name,
            categoryName: 'Unknown',
            currentStock: product.currentStock,
            minStockLevel: product.minStockLevel,
            alertType: 'low_stock',
          ),
        );
      }
    }

    // Sort: out of stock first, then low stock
    alerts.sort((a, b) {
      if (a.alertType == 'out_of_stock' && b.alertType != 'out_of_stock')
        return -1;
      if (a.alertType != 'out_of_stock' && b.alertType == 'out_of_stock')
        return 1;
      return a.currentStock.compareTo(b.currentStock);
    });

    return alerts;
  }

  // Get category-wise inventory
  List<CategoryInventory> getCategoryInventory(
    List<Product> products,
    List<Category> categories,
  ) {
    final categoryMap = <String, CategoryInventory>{};

    // Initialize all categories
    for (final category in categories) {
      categoryMap[category.id!] = CategoryInventory(
        categoryId: category.id!,
        categoryName: category.name,
        productCount: 0,
        stockValue: 0.0,
        lowStockCount: 0,
      );
    }

    // Calculate inventory for each category
    for (final product in products) {
      if (categoryMap.containsKey(product.categoryId)) {
        final current = categoryMap[product.categoryId]!;
        final stockValue = product.currentStock * product.sellingPrice;
        final isLowStock = product.isLowStock;

        categoryMap[product.categoryId] = CategoryInventory(
          categoryId: current.categoryId,
          categoryName: current.categoryName,
          productCount: current.productCount + 1,
          stockValue: current.stockValue + stockValue,
          lowStockCount: current.lowStockCount + (isLowStock ? 1 : 0),
        );
      }
    }

    return categoryMap.values.toList()
      ..sort((a, b) => b.stockValue.compareTo(a.stockValue));
  }

  // Get products needing restock
  List<Product> getProductsNeedingRestock(List<Product> products) {
    return products
        .where((product) => product.isLowStock || product.currentStock == 0)
        .toList()
      ..sort((a, b) => a.currentStock.compareTo(b.currentStock));
  }

  // Calculate inventory turnover (simplified)
  double calculateInventoryTurnover(
    List<Sale> sales,
    List<Product> products,
    DateTime startDate,
    DateTime endDate,
  ) {
    final periodSales = sales
        .where(
          (sale) =>
              sale.dateTime.isAfter(startDate) &&
              sale.dateTime.isBefore(endDate),
        )
        .toList();

    if (periodSales.isEmpty) return 0.0;

    final totalSales = periodSales.fold(
      0.0,
      (sum, sale) => sum + sale.totalAmount,
    );
    final averageInventory =
        products.fold(0.0, (sum, product) {
          return sum + (product.currentStock * product.buyingPrice);
        }) /
        products.length;

    return averageInventory > 0 ? totalSales / averageInventory : 0.0;
  }
}
