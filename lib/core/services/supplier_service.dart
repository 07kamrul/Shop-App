import 'api_service.dart';

class SupplierService {
  // Get all suppliers
  static Future<List<dynamic>> getSuppliers() async {
    final response = await ApiService.get('/suppliers');
    return List<dynamic>.from(response);
  }

  // Get supplier by ID
  static Future<dynamic> getSupplier(String id) async {
    return await ApiService.get('/suppliers/$id');
  }

  // Create new supplier
  static Future<dynamic> createSupplier({
    required String name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
  }) async {
    final data = {
      'name': name,
      'contactPerson': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
    };

    return await ApiService.post('/suppliers', data);
  }

  // Update supplier
  static Future<dynamic> updateSupplier({
    required String id,
    required String name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
  }) async {
    final data = {
      'name': name,
      'contactPerson': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
    };

    return await ApiService.put('/suppliers/$id', data);
  }

  // Delete supplier
  static Future<void> deleteSupplier(String id) async {
    await ApiService.delete('/suppliers/$id');
  }

  // Search suppliers - FIXED: using named parameter
  static Future<List<dynamic>> searchSuppliers(String query) async {
    final response = await ApiService.get(
      '/suppliers/search',
      queryParams: {'query': query},
    );
    return List<dynamic>.from(response);
  }

  // Get top suppliers - FIXED: using named parameter
  static Future<List<dynamic>> getTopSuppliers({int limit = 10}) async {
    final response = await ApiService.get(
      '/suppliers/top',
      queryParams: {'limit': limit.toString()},
    );
    return List<dynamic>.from(response);
  }
}
