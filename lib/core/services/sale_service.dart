import 'api_service.dart';

class SaleService {
  // Get all sales
  static Future<List<dynamic>> getSales({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final response = await ApiService.get(
      '/sales',
      queryParams: queryParams, // Fixed: using named parameter
    );
    return List<dynamic>.from(response);
  }

  // Get sale by ID
  static Future<dynamic> getSale(String id) async {
    return await ApiService.get('/sales/$id');
  }

  // Create new sale
  static Future<dynamic> createSale({
    String? customerId,
    String? customerName,
    String? customerPhone,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    final data = {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'paymentMethod': paymentMethod,
      'items': items,
    };

    return await ApiService.post('/sales', data);
  }

  // Delete sale
  static Future<void> deleteSale(String id) async {
    await ApiService.delete('/sales/$id');
  }

  // Get today's sales
  static Future<List<dynamic>> getTodaySales() async {
    final response = await ApiService.get('/sales/today');
    return List<dynamic>.from(response);
  }
}
