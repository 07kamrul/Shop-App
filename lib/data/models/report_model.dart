import 'package:equatable/equatable.dart';

class DailySalesReport extends Equatable {
  final DateTime date;
  final double totalSales;
  final double totalProfit;
  final int totalTransactions;
  final List<ProductSales> topProducts;

  const DailySalesReport({
    required this.date,
    required this.totalSales,
    required this.totalProfit,
    required this.totalTransactions,
    required this.topProducts,
  });

  // Convert from JSON (API response)
  factory DailySalesReport.fromJson(Map<String, dynamic> json) {
    final topProducts =
        (json['topProducts'] as List<dynamic>?)
            ?.map(
              (product) =>
                  ProductSales.fromJson(product as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return DailySalesReport(
      date: DateTime.parse(json['date']),
      totalSales: (json['totalSales'] ?? 0).toDouble(),
      totalProfit: (json['totalProfit'] ?? 0).toDouble(),
      totalTransactions: json['totalTransactions'] ?? 0,
      topProducts: topProducts,
    );
  }

  // Convert to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().substring(0, 10), // YYYY-MM-DD format
      'totalSales': totalSales,
      'totalProfit': totalProfit,
      'totalTransactions': totalTransactions,
      'topProducts': topProducts.map((product) => product.toJson()).toList(),
    };
  }

  // Helper methods
  double get averageTransactionValue =>
      totalTransactions > 0 ? totalSales / totalTransactions : 0.0;

  double get profitMargin =>
      totalSales > 0 ? (totalProfit / totalSales) * 100 : 0.0;

  DailySalesReport copyWith({
    DateTime? date,
    double? totalSales,
    double? totalProfit,
    int? totalTransactions,
    List<ProductSales>? topProducts,
  }) {
    return DailySalesReport(
      date: date ?? this.date,
      totalSales: totalSales ?? this.totalSales,
      totalProfit: totalProfit ?? this.totalProfit,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      topProducts: topProducts ?? this.topProducts,
    );
  }

  @override
  List<Object?> get props => [
    date,
    totalSales,
    totalProfit,
    totalTransactions,
    topProducts,
  ];
}

class ProductSales extends Equatable {
  final String productId;
  final String productName;
  final int quantitySold;
  final double totalSales;
  final double totalProfit;

  const ProductSales({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.totalSales,
    required this.totalProfit,
  });

  // Convert from JSON (API response)
  factory ProductSales.fromJson(Map<String, dynamic> json) {
    return ProductSales(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      quantitySold: json['quantitySold'] ?? 0,
      totalSales: (json['totalSales'] ?? 0).toDouble(),
      totalProfit: (json['totalProfit'] ?? 0).toDouble(),
    );
  }

  // Convert to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantitySold': quantitySold,
      'totalSales': totalSales,
      'totalProfit': totalProfit,
    };
  }

  // Helper methods
  double get averagePrice => quantitySold > 0 ? totalSales / quantitySold : 0.0;

  double get profitMargin =>
      totalSales > 0 ? (totalProfit / totalSales) * 100 : 0.0;

  double get profitPerUnit =>
      quantitySold > 0 ? totalProfit / quantitySold : 0.0;

  ProductSales copyWith({
    String? productId,
    String? productName,
    int? quantitySold,
    double? totalSales,
    double? totalProfit,
  }) {
    return ProductSales(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantitySold: quantitySold ?? this.quantitySold,
      totalSales: totalSales ?? this.totalSales,
      totalProfit: totalProfit ?? this.totalProfit,
    );
  }

  @override
  List<Object?> get props => [
    productId,
    productName,
    quantitySold,
    totalSales,
    totalProfit,
  ];
}

class CategoryReport extends Equatable {
  final String categoryId;
  final String categoryName;
  final double totalSales;
  final double totalProfit;
  final double profitMargin;

  const CategoryReport({
    required this.categoryId,
    required this.categoryName,
    required this.totalSales,
    required this.totalProfit,
    required this.profitMargin,
  });

  // Convert from JSON (API response)
  factory CategoryReport.fromJson(Map<String, dynamic> json) {
    return CategoryReport(
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      totalSales: (json['totalSales'] ?? 0).toDouble(),
      totalProfit: (json['totalProfit'] ?? 0).toDouble(),
      profitMargin: (json['profitMargin'] ?? 0).toDouble(),
    );
  }

  // Convert to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'totalSales': totalSales,
      'totalProfit': totalProfit,
      'profitMargin': profitMargin,
    };
  }

  // Helper methods
  double get salesPercentage =>
      totalSales > 0 ? totalSales : 0.0; // Can be calculated relative to total

  double get profitPercentage => totalProfit > 0
      ? totalProfit
      : 0.0; // Can be calculated relative to total

  CategoryReport copyWith({
    String? categoryId,
    String? categoryName,
    double? totalSales,
    double? totalProfit,
    double? profitMargin,
  }) {
    return CategoryReport(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      totalSales: totalSales ?? this.totalSales,
      totalProfit: totalProfit ?? this.totalProfit,
      profitMargin: profitMargin ?? this.profitMargin,
    );
  }

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    totalSales,
    totalProfit,
    profitMargin,
  ];
}

class ProfitLossReport extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final double totalRevenue;
  final double totalCost;
  final double grossProfit;
  final double grossProfitMargin;
  final List<CategoryReport> categoryBreakdown;
  final double? operatingExpenses;
  final double? netProfit;
  final double? netProfitMargin;

  const ProfitLossReport({
    required this.startDate,
    required this.endDate,
    required this.totalRevenue,
    required this.totalCost,
    required this.grossProfit,
    required this.grossProfitMargin,
    required this.categoryBreakdown,
    this.operatingExpenses,
    this.netProfit,
    this.netProfitMargin,
  });

  // Convert from JSON (API response)
  factory ProfitLossReport.fromJson(Map<String, dynamic> json) {
    final categoryBreakdown =
        (json['categoryBreakdown'] as List<dynamic>?)
            ?.map(
              (category) =>
                  CategoryReport.fromJson(category as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return ProfitLossReport(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      grossProfit: (json['grossProfit'] ?? 0).toDouble(),
      grossProfitMargin: (json['grossProfitMargin'] ?? 0).toDouble(),
      categoryBreakdown: categoryBreakdown,
      operatingExpenses: (json['operatingExpenses'] ?? 0).toDouble(),
      netProfit: (json['netProfit'] ?? 0).toDouble(),
      netProfitMargin: (json['netProfitMargin'] ?? 0).toDouble(),
    );
  }

  // Convert to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String().substring(0, 10),
      'endDate': endDate.toIso8601String().substring(0, 10),
      'totalRevenue': totalRevenue,
      'totalCost': totalCost,
      'grossProfit': grossProfit,
      'grossProfitMargin': grossProfitMargin,
      'categoryBreakdown': categoryBreakdown
          .map((category) => category.toJson())
          .toList(),
      if (operatingExpenses != null) 'operatingExpenses': operatingExpenses,
      if (netProfit != null) 'netProfit': netProfit,
      if (netProfitMargin != null) 'netProfitMargin': netProfitMargin,
    };
  }

  // Helper methods
  String get dateRange =>
      '${startDate.toIso8601String().substring(0, 10)} to ${endDate.toIso8601String().substring(0, 10)}';

  double get calculatedGrossProfit => totalRevenue - totalCost;

  double get calculatedGrossProfitMargin =>
      totalRevenue > 0 ? (calculatedGrossProfit / totalRevenue) * 100 : 0.0;

  // For API request parameters
  Map<String, dynamic> toRequestParams() {
    return {
      'startDate': startDate.toIso8601String().substring(0, 10),
      'endDate': endDate.toIso8601String().substring(0, 10),
    };
  }

  ProfitLossReport copyWith({
    DateTime? startDate,
    DateTime? endDate,
    double? totalRevenue,
    double? totalCost,
    double? grossProfit,
    double? grossProfitMargin,
    List<CategoryReport>? categoryBreakdown,
    double? operatingExpenses,
    double? netProfit,
    double? netProfitMargin,
  }) {
    return ProfitLossReport(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalCost: totalCost ?? this.totalCost,
      grossProfit: grossProfit ?? this.grossProfit,
      grossProfitMargin: grossProfitMargin ?? this.grossProfitMargin,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      operatingExpenses: operatingExpenses ?? this.operatingExpenses,
      netProfit: netProfit ?? this.netProfit,
      netProfitMargin: netProfitMargin ?? this.netProfitMargin,
    );
  }

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    totalRevenue,
    totalCost,
    grossProfit,
    grossProfitMargin,
    categoryBreakdown,
    operatingExpenses,
    netProfit,
    netProfitMargin,
  ];
}
