
import '../../data/models/sale_model.dart';

class Calculations {
  // Calculate profit for a single product
  static double calculateProfit({
    required double sellingPrice,
    required double buyingPrice,
    required int quantity,
  }) {
    return (sellingPrice - buyingPrice) * quantity;
  }

  // Calculate total from list of sales
  static double calculateTotalSales(List<Sale> sales) {
    return sales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
  }

  // Calculate total profit from list of sales
  static double calculateTotalProfit(List<Sale> sales) {
    return sales.fold(0.0, (sum, sale) => sum + sale.totalProfit);
  }

  // Ensure double type
  static double ensureDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
    static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  static double calculateProfitMargin(double revenue, double cost) {
    return revenue > 0 ? ((revenue - cost) / revenue) * 100 : 0.0;
  }

  static double calculateNetProfitMargin(double netProfit, double revenue) {
    return revenue > 0 ? (netProfit / revenue) * 100 : 0.0;
  }
}
