import 'api_service.dart';

class ReportService {
  // Get profit and loss report
  static Future<dynamic> getProfitLossReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final queryParams = {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };

    return await ApiService.get(
      '/reports/profit-loss',
      queryParams: queryParams,
    );
  }

  // Get daily sales report
  static Future<List<dynamic>> getDailySalesReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final queryParams = {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };

    final response = await ApiService.get(
      '/reports/daily-sales',
      queryParams: queryParams,
    );
    return List<dynamic>.from(response);
  }

  // Get top selling products
  static Future<List<dynamic>> getTopSellingProducts({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  }) async {
    final queryParams = {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'limit': limit.toString(),
    };

    final response = await ApiService.get(
      '/reports/top-products',
      queryParams: queryParams,
    );
    return List<dynamic>.from(response);
  }
}
