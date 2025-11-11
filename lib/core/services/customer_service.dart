import 'api_service.dart';

class CustomerService {
  // Get all customers
  static Future<List<dynamic>> getCustomers() async {
    final response = await ApiService.get('/customers');
    return List<dynamic>.from(response);
  }

  // Get customer by ID
  static Future<dynamic> getCustomer(String id) async {
    return await ApiService.get('/customers/$id');
  }

  // Create new customer
  static Future<dynamic> createCustomer({
    required String name,
    String? phone,
    String? email,
    String? address,
  }) async {
    final data = {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
    };

    return await ApiService.post('/customers', data);
  }

  // Update customer
  static Future<dynamic> updateCustomer({
    required String id,
    required String name,
    String? phone,
    String? email,
    String? address,
  }) async {
    final data = {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
    };

    return await ApiService.put('/customers/$id', data);
  }

  // Delete customer
  static Future<void> deleteCustomer(String id) async {
    await ApiService.delete('/customers/$id');
  }

  // Search customers - FIXED: Use named parameter
  static Future<List<dynamic>> searchCustomers(String query) async {
    final response = await ApiService.get(
      '/customers/search',
      queryParams: {'query': query},
    );
    return List<dynamic>.from(response);
  }

  // Get top customers - FIXED: Use named parameter
  static Future<List<dynamic>> getTopCustomers({int limit = 10}) async {
    final response = await ApiService.get(
      '/customers/top',
      queryParams: {'limit': limit.toString()},
    );
    return List<dynamic>.from(response);
  }
}
