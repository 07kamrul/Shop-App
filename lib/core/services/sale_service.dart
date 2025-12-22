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

    final response = await ApiService.get('/sales', queryParams: queryParams);
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
      if (customerId != null && customerId.isNotEmpty) 'customerId': customerId,
      if (customerName != null && customerName.isNotEmpty)
        'customerName': customerName,
      if (customerPhone != null && customerPhone.isNotEmpty)
        'customerPhone': customerPhone,
      'paymentMethod': paymentMethod,
      'items': items,
    };

    return await ApiService.post('/sales', data);
  }

  // Update existing sale
  static Future<dynamic> updateSale({
    required String saleId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    final data = {
      if (customerId != null && customerId.isNotEmpty) 'customerId': customerId,
      if (customerName != null && customerName.isNotEmpty)
        'customerName': customerName,
      if (customerPhone != null && customerPhone.isNotEmpty)
        'customerPhone': customerPhone,
      'paymentMethod': paymentMethod,
      'items': items
          .map(
            (item) => {
              'productId': item['productId'],
              'quantity': item['quantity'],
              'unitSellingPrice': item['unitSellingPrice'],
            },
          )
          .toList(),
    };

    return await ApiService.put('/sales/$saleId', data);
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
